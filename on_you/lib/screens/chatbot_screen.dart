import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../models/recommended_product.dart';
import '../services/api_service.dart';

class ChatBotScreen extends StatefulWidget {
  final bool autoStartQuickAnalysis;
  final String? autoQuickImagePath;

  final bool autoStartDetailedAnalysis;
  final String? autoFrontPath;
  final String? autoLeftPath;
  final String? autoRightPath;

  final bool autoStartIngredientAnalysis;
  final String? autoIngredientImagePath;

  final bool autoStartPersonalColorAnalysis;
  final String? autoPersonalColorImagePath;
  final String? initialPrompt;

  const ChatBotScreen({
    super.key,
    this.initialPrompt,
    this.autoStartQuickAnalysis = false,
    this.autoQuickImagePath,
    this.autoStartDetailedAnalysis = false,
    this.autoFrontPath,
    this.autoLeftPath,
    this.autoRightPath,
    this.autoStartIngredientAnalysis = false,
    this.autoIngredientImagePath,
    this.autoStartPersonalColorAnalysis = false,
    this.autoPersonalColorImagePath,
  });

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _analysisButtonKey = GlobalKey();

  final List<ChatMessage> _messages = [];
  final List<ChatSession> _chatHistory = [];
  final ImagePicker _picker = ImagePicker();

  final List<String> _suggestions = const [
    '피부 타입 알고 싶어요',
    '보습 크림 추천해줘',
    '여드름 케어 방법',
    '성분 분석 해줘',
  ];

  int? _chatRoomId;
  int? _currentUserId;
  AnalysisType _selectedAnalysis = AnalysisType.none;
  final List<PickedChatImage> _pickedImages = [];

  bool _showAnalysisPanel = false;
  bool _isSending = false;

  bool _isHistoryPanelOpen = false;
  bool _isHistoryDeleteMode = false;
  bool _isHistoryLoading = false;

  bool _didRunAutoDetailedAnalysis = false;
  bool _didRunInitialPrompt = false;

  final Set<int> _selectedHistoryIds = {};

  /// key: product_vector_id(or goodsNo) / value: wish_id
  final Map<String, int> _savedWishIdByVectorId = {};

  @override
  void initState() {
    super.initState();

    _initializeScreen().then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _runAutoAnalysisIfNeeded();
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runAutoDetailedAnalysisIfNeeded();
    });
  }


  Future<void> _initializeScreen() async {
    await _loadCurrentUser();
    await _loadChatRooms();
    await _loadWishlistState();
  }

  Future<void> _runAutoDetailedAnalysisIfNeeded() async {
    if (_didRunAutoDetailedAnalysis) return;
    _didRunAutoDetailedAnalysis = true;

    if (!widget.autoStartDetailedAnalysis) return;
    if (widget.autoFrontPath == null ||
        widget.autoLeftPath == null ||
        widget.autoRightPath == null) {
      return;
    }

    try {
      final frontBytes = await File(widget.autoFrontPath!).readAsBytes();
      final leftBytes = await File(widget.autoLeftPath!).readAsBytes();
      final rightBytes = await File(widget.autoRightPath!).readAsBytes();

      final pickedFiles = [
        PickedChatImage(
          file: XFile(widget.autoFrontPath!),
          bytes: frontBytes,
        ),
        PickedChatImage(
          file: XFile(widget.autoLeftPath!),
          bytes: leftBytes,
        ),
        PickedChatImage(
          file: XFile(widget.autoRightPath!),
          bytes: rightBytes,
        ),
      ];

      if (!mounted) return;

      setState(() {
        _isSending = true;
        _selectedAnalysis = AnalysisType.detail;
        _messages.add(
          ChatMessage(
            text: '피부 정밀 분석 요청',
            isUser: true,
            images: [frontBytes, leftBytes, rightBytes],
          ),
        );
      });

      _scrollToBottom();

      await _sendAnalysisRequest(
        selectedType: AnalysisType.detail,
        pickedFiles: pickedFiles,
        userText: '피부 정밀 분석 해줘',
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _messages.add(
          ChatMessage(
            text: '정밀 분석을 시작하지 못했어요.\n$e',
            isUser: false,
          ),
        );
      });
    } finally {
      if (!mounted) return;

      setState(() {
        _isSending = false;
        _selectedAnalysis = AnalysisType.none;
        _pickedImages.clear();
        _showAnalysisPanel = false;
      });

      _scrollToBottom();
    }
  }

  Future<void> _loadCurrentUser() async {
    try {
      final me = await ApiService.getMe();
      final userId = _toInt(me['user_id'] ?? me['id']);

      if (!mounted) return;

      setState(() {
        _currentUserId = userId;
      });
    } catch (e) {
      debugPrint('내 정보 불러오기 실패: $e');
    }
  }

  Future<void> _loadWishlistState() async {
    try {
      final items = await ApiService.getWishlist();
      final mapped = <String, int>{};

      for (final item in items) {
        if (item is! Map) continue;
        final map = Map<String, dynamic>.from(item);
        final wishId = _toInt(map['wish_id'] ?? map['id']);
        final vectorId = (map['product_vector_id']?.toString() ?? '').trim();

        if (wishId != null && vectorId.isNotEmpty) {
          mapped[vectorId] = wishId;
        }
      }

      if (!mounted) return;

      setState(() {
        _savedWishIdByVectorId
          ..clear()
          ..addAll(mapped);
      });
    } catch (e) {
      debugPrint('위시리스트 상태 불러오기 실패: $e');
    }
  }

  Future<void> _runAutoAnalysisIfNeeded() async {
    if (!mounted) return;

    if (widget.autoStartIngredientAnalysis &&
        widget.autoIngredientImagePath != null &&
        widget.autoIngredientImagePath!.trim().isNotEmpty) {
      await _autoStartSingleImageAnalysis(
        imagePath: widget.autoIngredientImagePath!,
        type: AnalysisType.ingredient,
        prompt: '화장품 성분 분석 해줘',
      );
      return;
    }

    if (_didRunInitialPrompt) return;

    final prompt = widget.initialPrompt?.trim() ?? '';
    if (prompt.isEmpty) return;

    _didRunInitialPrompt = true;
    await _sendMessage(prompt);

    if (widget.autoStartPersonalColorAnalysis &&
        widget.autoPersonalColorImagePath != null &&
        widget.autoPersonalColorImagePath!.trim().isNotEmpty) {
      await _autoStartSingleImageAnalysis(
        imagePath: widget.autoPersonalColorImagePath!,
        type: AnalysisType.personalColor,
        prompt: '퍼스널 컬러 진단 해줘',
      );
      return;
    }

    if (widget.autoStartQuickAnalysis &&
        widget.autoQuickImagePath != null &&
        widget.autoQuickImagePath!.trim().isNotEmpty) {
      await _autoStartSingleImageAnalysis(
        imagePath: widget.autoQuickImagePath!,
        type: AnalysisType.normal,
        prompt: '피부 빠른 분석 해줘',
      );
      return;
    }
  }

  Future<void> _autoStartSingleImageAnalysis({
    required String imagePath,
    required AnalysisType type,
    required String prompt,
  }) async {
    try {
      final file = XFile(imagePath);
      final bytes = await file.readAsBytes();

      if (!mounted) return;

      setState(() {
        _selectedAnalysis = type;
        _showAnalysisPanel = false;
        _pickedImages
          ..clear()
          ..add(PickedChatImage(file: file, bytes: bytes));
      });

      await _sendMessage(prompt);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('자동 분석을 시작하지 못했어요.\n$e'),
        ),
      );
    }
  }

  Future<int?> _ensureCurrentUserId() async {
    if (_currentUserId != null) return _currentUserId;

    try {
      final me = await ApiService.getMe();
      final userId = _toInt(me['user_id'] ?? me['id']);

      if (!mounted) return userId;

      setState(() {
        _currentUserId = userId;
      });

      return userId;
    } catch (e) {
      debugPrint('유저 ID 확인 실패: $e');
      return null;
    }
  }

  String _extractGoodsNo(String url) {
    final regExp = RegExp(r'goodsNo=([A-Za-z0-9]+)');
    final match = regExp.firstMatch(url);
    return match?.group(1)?.trim() ?? '';
  }

  String _resolveProductVectorId(RecommendedProduct product) {
    final directId = product.productVectorId.trim();
    if (directId.isNotEmpty) return directId;

    final goodsNo = _extractGoodsNo(product.url);
    if (goodsNo.isNotEmpty) return goodsNo;

    return '';
  }

  bool _isProductSaved(RecommendedProduct product) {
    final vectorId = _resolveProductVectorId(product);
    if (vectorId.isEmpty) return false;
    return _savedWishIdByVectorId.containsKey(vectorId);
  }

  Future<void> _toggleWishlistProduct({
    required ChatMessage message,
    required RecommendedProduct product,
  }) async {
    try {
      final vectorId = _resolveProductVectorId(product);

      if (vectorId.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('이 추천 상품은 저장용 제품 ID가 없어 위시리스트에 담을 수 없어요.'),
          ),
        );
        return;
      }

      final savedWishId = _savedWishIdByVectorId[vectorId];

      if (savedWishId != null) {
        await ApiService.removeWishlist(savedWishId);

        if (!mounted) return;

        setState(() {
          _savedWishIdByVectorId.remove(vectorId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('위시리스트에서 제거했어요.'),
            duration: Duration(milliseconds: 900),
          ),
        );
        return;
      }

      final userId = await _ensureCurrentUserId();
      if (userId == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('로그인 정보를 확인하지 못했어요. 다시 시도해주세요.'),
          ),
        );
        return;
      }

      final saved = await ApiService.addWishlist(
        userId: userId,
        productVectorId: vectorId,
        productName: product.title,
        messageId: message.messageId,
        productDescription: product.description,
      );

      final wishId = _toInt(saved['wish_id'] ?? saved['id']);
      if (wishId == null) {
        throw Exception('저장 후 wish_id를 받지 못했어요.');
      }

      if (!mounted) return;

      setState(() {
        _savedWishIdByVectorId[vectorId] = wishId;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('위시리스트에 추가했어요.'),
          duration: Duration(milliseconds: 900),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('위시리스트 저장 중 오류가 발생했어요.\n$e'),
        ),
      );
    }
  }

  Future<void> _showPhotoGuide() async {
    FocusScope.of(context).unfocus();

    await showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (_) => _PhotoGuideDialog(
        analysisType: _selectedAnalysis,
      ),
    );
  }

  Future<void> _loadChatRooms() async {
    try {
      if (mounted) {
        setState(() {
          _isHistoryLoading = true;
        });
      }

      final rooms = await ApiService.getChatRooms();
      final parsed = rooms
          .map((item) => _mapChatSession(item))
          .whereType<ChatSession>()
          .toList();

      if (!mounted) return;

      setState(() {
        _chatHistory
          ..clear()
          ..addAll(parsed);
      });
    } catch (e) {
      debugPrint('채팅방 목록 불러오기 실패: $e');
    } finally {
      if (!mounted) return;
      setState(() {
        _isHistoryLoading = false;
      });
    }
  }

  ChatSession? _mapChatSession(dynamic raw) {
    if (raw is! Map) return null;

    final map = Map<String, dynamic>.from(raw);

    final roomId = _toInt(
      map['chat_room_id'] ?? map['id'] ?? map['room_id'],
    );
    if (roomId == null) return null;

    final title = (map['title']?.toString().trim().isNotEmpty ?? false)
        ? map['title'].toString().trim()
        : '새 채팅';

    final preview = (map['preview']?.toString() ?? '').trim();

    final updatedAt =
        _parseDateTime(map['updated_at'] ?? map['created_at']) ??
            DateTime.now();

    return ChatSession(
      roomId: roomId,
      title: title,
      preview: preview,
      updatedAt: updatedAt,
    );
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  Future<void> _loadMessagesForRoom(int roomId) async {
    try {
      final rawMessages = await ApiService.getChatMessages(roomId);

      final parsedMessages = rawMessages
          .map((item) => _mapChatMessage(item))
          .whereType<ChatMessage>()
          .toList();

      if (!mounted) return;

      setState(() {
        _chatRoomId = roomId;
        _messages
          ..clear()
          ..addAll(parsedMessages);
        _pickedImages.clear();
        _selectedAnalysis = AnalysisType.none;
        _showAnalysisPanel = false;
      });

      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('채팅 내용을 불러오지 못했어요.\n$e')),
      );
    }
  }

  ChatMessage? _mapChatMessage(dynamic raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);

    final messageId = _toInt(map['message_id'] ?? map['id']);
    final role = (map['role']?.toString() ?? '').trim();
    final content = (map['content']?.toString() ?? '').trim();

    final recommendedProducts = _extractRecommendedProducts(map, content);
    final cleanedText =
    role == 'assistant' ? _cleanAssistantText(content) : content;

    final messageText =
    cleanedText.isEmpty && recommendedProducts.isEmpty ? content : cleanedText;

    return ChatMessage(
      text: messageText,
      isUser: role == 'user',
      messageId: messageId,
      recommendedProducts: recommendedProducts,
    );
  }

  String _formatHistoryDate(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inDays == 0) return '오늘';
    if (diff.inDays == 1) return '1일 전';
    return '${diff.inDays}일 전';
  }

  void _toggleHistoryPanel() async {
    FocusScope.of(context).unfocus();

    final opening = !_isHistoryPanelOpen;

    setState(() {
      _isHistoryPanelOpen = opening;

      if (!_isHistoryPanelOpen) {
        _isHistoryDeleteMode = false;
        _selectedHistoryIds.clear();
      }
    });

    if (opening) {
      await _loadChatRooms();
    }
  }

  void _closeHistoryPanel() {
    setState(() {
      _isHistoryPanelOpen = false;
      _isHistoryDeleteMode = false;
      _selectedHistoryIds.clear();
    });
  }

  void _toggleHistoryDeleteMode() {
    setState(() {
      _isHistoryDeleteMode = !_isHistoryDeleteMode;

      if (!_isHistoryDeleteMode) {
        _selectedHistoryIds.clear();
      }
    });
  }

  void _toggleHistorySelection(int roomId) {
    setState(() {
      if (_selectedHistoryIds.contains(roomId)) {
        _selectedHistoryIds.remove(roomId);
      } else {
        _selectedHistoryIds.add(roomId);
      }
    });
  }

  Future<void> _deleteSelectedHistory() async {
    if (_selectedHistoryIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('지울 채팅을 선택해주세요.'),
        ),
      );
      return;
    }

    final selectedIds = _selectedHistoryIds.toList();

    try {
      for (final roomId in selectedIds) {
        await ApiService.deleteChatRoom(roomId);
      }

      if (!mounted) return;

      final deletingCurrentChat =
          _chatRoomId != null && _selectedHistoryIds.contains(_chatRoomId);

      setState(() {
        _chatHistory.removeWhere(
              (chat) => _selectedHistoryIds.contains(chat.roomId),
        );

        if (deletingCurrentChat) {
          _chatRoomId = null;
          _messages.clear();
        }

        _selectedHistoryIds.clear();
        _isHistoryDeleteMode = false;
        _isHistoryPanelOpen = false;
      });

      await _loadChatRooms();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('채팅 삭제 중 오류가 발생했어요.\n$e')),
      );
    }
  }

  Future<void> _openAnalysisMenu() async {
    FocusScope.of(context).unfocus();

    final buttonContext = _analysisButtonKey.currentContext;
    if (buttonContext == null) return;

    final RenderBox button = buttonContext.findRenderObject() as RenderBox;
    final RenderBox overlay =
    Overlay.of(context).context.findRenderObject() as RenderBox;

    final topLeft = button.localToGlobal(Offset.zero, ancestor: overlay);
    final bottomRight = button.localToGlobal(
      button.size.bottomRight(Offset.zero),
      ancestor: overlay,
    );

    const double menuWidth = 220;
    const double menuHeight = 310;

    final double left = (bottomRight.dx - menuWidth)
        .clamp(12.0, overlay.size.width - menuWidth - 12.0);

    final double top = (topLeft.dy - menuHeight - 8)
        .clamp(12.0, overlay.size.height - menuHeight - 12.0);

    final selected = await showGeneralDialog<AnalysisType>(
      context: context,
      barrierLabel: 'analysis_menu',
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 140),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(color: Colors.transparent),
              ),
            ),
            Positioned(
              left: left,
              top: top,
              width: menuWidth,
              child: _AnalysisPopupCard(
                selectedAnalysis: _selectedAnalysis,
              ),
            ),
          ],
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            ),
            alignment: Alignment.bottomRight,
            child: child,
          ),
        );
      },
    );

    if (selected != null) {
      _selectAnalysisType(selected);
    }
  }

  void _selectAnalysisType(AnalysisType type) {
    setState(() {
      if (_selectedAnalysis != type) {
        _pickedImages.clear();
      }

      _selectedAnalysis = type;
      _showAnalysisPanel = type != AnalysisType.none;
    });
  }

  Future<void> _pickImageForAnalysis() async {
    if (_selectedAnalysis == AnalysisType.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('먼저 분석 유형을 선택해주세요.')),
      );
      return;
    }

    if (_pickedImages.length >= _selectedAnalysis.maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_selectedAnalysis.label}은 최대 ${_selectedAnalysis.maxImages}장까지 올릴 수 있어요.',
          ),
        ),
      );
      return;
    }

    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );

    if (picked == null) return;

    final bytes = await picked.readAsBytes();

    setState(() {
      _pickedImages.add(
        PickedChatImage(file: picked, bytes: bytes),
      );
    });
  }

  void _removePickedImage(int index) {
    setState(() {
      _pickedImages.removeAt(index);
    });
  }

  String _modelTypeForApi(AnalysisType type) {
    switch (type) {
      case AnalysisType.normal:
        return 'simple';
      case AnalysisType.detail:
        return 'detailed';
      case AnalysisType.ingredient:
        return 'ingredient';
      case AnalysisType.personalColor:
        return 'personal';
      case AnalysisType.none:
        return 'default';
    }
  }

  String _defaultPromptForAnalysis(AnalysisType type) {
    switch (type) {
      case AnalysisType.normal:
        return '피부 빠른 분석 해줘';
      case AnalysisType.detail:
        return '피부 정밀 분석 해줘';
      case AnalysisType.ingredient:
        return '화장품 성분 분석 해줘';
      case AnalysisType.personalColor:
        return '퍼스널 컬러 진단 해줘';
      case AnalysisType.none:
        return '분석해줘';
    }
  }

  List<String> _analysisToStringList(dynamic value) {
    if (value is List) {
      return value
          .map((e) => e?.toString().trim() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return [];
  }

  String _buildAnalysisResultText({
    required AnalysisType type,
    required Map<String, dynamic> result,
  }) {
    final buffer = StringBuffer();

    String title;
    switch (type) {
      case AnalysisType.normal:
        title = '빠른 피부 분석 결과';
        break;
      case AnalysisType.detail:
        title = '정밀 피부 분석 결과';
        break;
      case AnalysisType.ingredient:
        title = '성분 분석 결과';
        break;
      case AnalysisType.personalColor:
        title = '퍼스널 컬러 진단 결과';
        break;
      case AnalysisType.none:
        title = '분석 결과';
        break;
    }

    buffer.writeln('## $title');

    final skinScore = result['skin_score'];
    if (skinScore != null) {
      buffer.writeln('- 피부 점수: $skinScore점');
    }

    final summary = result['summary'] ??
        result['description'] ??
        result['analysis_text'] ??
        result['result_text'];
    if (summary != null && summary.toString().trim().isNotEmpty) {
      buffer.writeln('- 요약: ${summary.toString().trim()}');
    }

    final factors = _analysisToStringList(
      result['factorial'] ??
          result['factors'] ??
          result['concerns'] ??
          result['ingredients'],
    );
    if (factors.isNotEmpty) {
      buffer.writeln('- 주요 항목: ${factors.join(', ')}');
    }

    final tone = result['personal_color_type'] ??
        result['tone_name'] ??
        result['season'] ??
        result['tone'];
    if (tone != null && tone.toString().trim().isNotEmpty) {
      buffer.writeln('- 진단 타입: ${tone.toString().trim()}');
    }

    final recommendedColors = _analysisToStringList(
      result['recommended_colors'] ??
          result['recommended_color'] ??
          result['best_colors'],
    );
    if (recommendedColors.isNotEmpty) {
      buffer.writeln('- 추천 컬러: ${recommendedColors.join(', ')}');
    }

    final cautionColors = _analysisToStringList(
      result['caution_colors'] ??
          result['avoid_colors'] ??
          result['warnings'],
    );
    if (cautionColors.isNotEmpty) {
      buffer.writeln('- 주의 컬러/주의 항목: ${cautionColors.join(', ')}');
    }

    if (buffer.toString().trim() == '## $title') {
      final analysisData = result['analysis_data'];
      if (analysisData is Map && analysisData.isNotEmpty) {
        return '## $title\n- 상세 데이터: ${analysisData.toString()}';
      }
      return '$title가 도착했어요.';
    }

    return buffer.toString().trim();
  }

  Future<void> _sendChatRequest(String displayText) async {
    if (_chatRoomId == null) {
      final room = await ApiService.createChatRoom();
      _chatRoomId = _toInt(room['chat_room_id'] ?? room['id']);

      if (_chatRoomId == null) {
        throw Exception('채팅방 ID를 받지 못했어요.');
      }
    }

    final responseList = await ApiService.sendMessage(
      chatRoomId: _chatRoomId!,
      content: displayText,
      modelType: 'default',
      imageBytes: null,
      imageFileName: null,
      imageUrls: const [],
    );

    Map<String, dynamic>? aiMessageMap;
    for (final item in responseList) {
      if (item is Map<String, dynamic> && item['role'] == 'assistant') {
        aiMessageMap = item;
      }
    }

    final replyText =
        aiMessageMap?['content']?.toString() ?? '응답을 받았지만 내용이 비어 있어요.';

    final recommendedProducts =
    _extractRecommendedProducts(aiMessageMap, replyText);

    final cleanedReplyText = _cleanAssistantText(replyText);

    final messageText = cleanedReplyText.isEmpty && recommendedProducts.isEmpty
        ? replyText
        : cleanedReplyText;

    if (!mounted) return;

    setState(() {
      _messages.add(
        ChatMessage(
          text: messageText,
          isUser: false,
          messageId: _toInt(aiMessageMap?['message_id'] ?? aiMessageMap?['id']),
          recommendedProducts: recommendedProducts,
        ),
      );
    });

    await _loadChatRooms();
  }

  String _uploadTypeForAnalysis(AnalysisType type) {
    switch (type) {
      case AnalysisType.ingredient:
        return 'ingredient';
      case AnalysisType.normal:
      case AnalysisType.detail:
      case AnalysisType.personalColor:
        return 'quick';
      case AnalysisType.none:
        return 'quick';
    }
  }

  Future<void> _sendAnalysisRequest({
    required AnalysisType selectedType,
    required List<PickedChatImage> pickedFiles,
    required String userText,
  }) async {
    if (_chatRoomId == null) {
      final room = await ApiService.createChatRoom();
      _chatRoomId = _toInt(room['chat_room_id'] ?? room['id']);

      if (_chatRoomId == null) {
        throw Exception('채팅방 ID를 받지 못했어요.');
      }
    }

    final uploadType = _uploadTypeForAnalysis(selectedType);
    final uploadedUrls = <String>[];

    for (final picked in pickedFiles) {
      final url = await ApiService.uploadAnalysisImage(
        imageBytes: picked.bytes,
        fileName: picked.file.name,
        analysisType: uploadType,
      );
      uploadedUrls.add(url);
    }

    final promptText =
    userText.isNotEmpty ? userText : _defaultPromptForAnalysis(selectedType);

    final responseList = await ApiService.sendMessage(
      chatRoomId: _chatRoomId!,
      content: promptText,
      modelType: _modelTypeForApi(selectedType),
      imageBytes: null,
      imageFileName: null,
      imageUrls: uploadedUrls,
    );

    Map<String, dynamic>? aiMessageMap;
    for (final item in responseList) {
      if (item is Map<String, dynamic> && item['role'] == 'assistant') {
        aiMessageMap = item;
      }
    }

    final replyText =
        aiMessageMap?['content']?.toString() ?? '분석 응답을 받았지만 내용이 비어 있어요.';

    final recommendedProducts =
    _extractRecommendedProducts(aiMessageMap, replyText);

    final cleanedReplyText = _cleanAssistantText(replyText);

    final messageText = cleanedReplyText.isEmpty && recommendedProducts.isEmpty
        ? replyText
        : cleanedReplyText;

    if (!mounted) return;

    setState(() {
      _messages.add(
        ChatMessage(
          text: messageText,
          isUser: false,
          messageId: _toInt(aiMessageMap?['message_id'] ?? aiMessageMap?['id']),
          recommendedProducts: recommendedProducts,
        ),
      );
    });

    await _loadChatRooms();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  List<RecommendedProduct> _extractRecommendedProducts(
      Map<String, dynamic>? aiMessageMap,
      String replyText,
      ) {
    final products = <RecommendedProduct>[];
    final seen = <String>{};

    void addProduct({
      required String? title,
      required String? url,
      required String? productVectorId,
      required String? description,
    }) {
      final safeTitle = title?.trim() ?? '';
      final safeUrl = url?.trim() ?? '';
      final fallbackGoodsNo = _extractGoodsNo(safeUrl);
      final safeVectorId = (productVectorId?.trim().isNotEmpty ?? false)
          ? productVectorId!.trim()
          : fallbackGoodsNo;
      final safeDescription = description?.trim();

      if (safeTitle.isEmpty) return;

      final uniqueKey = safeVectorId.isNotEmpty
          ? safeVectorId
          : (safeUrl.isNotEmpty ? safeUrl : safeTitle);

      if (!seen.add(uniqueKey)) return;

      products.add(
        RecommendedProduct(
          productVectorId: safeVectorId,
          title: safeTitle,
          url: safeUrl,
          description: safeDescription,
        ),
      );
    }

    final rawProducts =
        aiMessageMap?['recommended_products'] ?? aiMessageMap?['products'];

    if (rawProducts is List) {
      for (final item in rawProducts) {
        if (item is Map) {
          addProduct(
            title:
            item['title']?.toString() ?? item['product_name']?.toString(),
            url: item['url']?.toString() ?? item['product_url']?.toString(),
            productVectorId: item['product_vector_id']?.toString(),
            description: item['description']?.toString() ??
                item['product_description']?.toString(),
          );
        }
      }
    }

    if (products.isEmpty) {
      final regExp = RegExp(r'\[([^\]]+)\]\((https?:\/\/[^\s)]+)\)');
      for (final match in regExp.allMatches(replyText)) {
        addProduct(
          title: match.group(1),
          url: match.group(2),
          productVectorId: '',
          description: null,
        );
      }
    }

    return products;
  }

  String _cleanAssistantText(String text) {
    var cleaned = text.replaceAll('\r\n', '\n');

    final productSection = RegExp(
      r'(\*\*🛒\s*올리브영 구매 링크\*\*|🛒\s*올리브영 구매 링크)',
      multiLine: true,
    );

    final match = productSection.firstMatch(cleaned);
    if (match != null) {
      cleaned = cleaned.substring(0, match.start).trim();
    }

    cleaned = cleaned.replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();

    return cleaned;
  }

  Future<void> _sendMessage([String? text]) async {
    if (_isSending) return;

    final inputText = (text ?? _controller.text).trim();
    final selectedType = _selectedAnalysis;
    final pickedFiles = List<PickedChatImage>.from(_pickedImages);

    final hasImages = pickedFiles.isNotEmpty;
    final isAnalysisMode = selectedType != AnalysisType.none;

    if (inputText.isEmpty && !hasImages) return;

    if (isAnalysisMode && !hasImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('분석할 사진을 먼저 업로드해주세요.')),
      );
      return;
    }

    if (isAnalysisMode && pickedFiles.length != selectedType.maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${selectedType.label}은 ${selectedType.maxImages}장의 사진이 필요해요.',
          ),
        ),
      );
      return;
    }

    final displayText = inputText.isNotEmpty
        ? inputText
        : selectedType == AnalysisType.ingredient
        ? '성분 분석 요청'
        : selectedType == AnalysisType.personalColor
        ? '퍼스널 컬러 진단 요청'
        : '피부 분석 요청';

    final sentImages = pickedFiles.map((e) => e.bytes).toList();

    _controller.clear();

    setState(() {
      _isSending = true;

      _messages.add(
        ChatMessage(
          text: displayText,
          isUser: true,
          images: sentImages,
        ),
      );

      _pickedImages.clear();
      _showAnalysisPanel = false;
    });

    _scrollToBottom();

    try {
      if (isAnalysisMode) {
        await _sendAnalysisRequest(
          selectedType: selectedType,
          pickedFiles: pickedFiles,
          userText: inputText,
        );
      } else {
        await _sendChatRequest(displayText);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _messages.add(
          ChatMessage(
            text: '서버 연결 중 오류가 발생했어요.\n$e',
            isUser: false,
          ),
        );
      });
    } finally {
      if (!mounted) return;

      setState(() {
        _isSending = false;
        _selectedAnalysis = AnalysisType.none;
      });

      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = _messages.isEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F0),
      body: Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              FocusScope.of(context).unfocus();

              if (_showAnalysisPanel) {
                setState(() {
                  _showAnalysisPanel = false;
                  _selectedAnalysis = AnalysisType.none;
                  _pickedImages.clear();
                });
              }
            },
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _ChatTopBar(
                    onHistoryTap: _toggleHistoryPanel,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: isEmpty
                        ? _EmptyChatView(
                      suggestions: _suggestions,
                      onSuggestionTap: (text) => _sendMessage(text),
                    )
                        : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        return _MessageBubble(
                          message: msg,
                          isProductSaved: _isProductSaved,
                          onToggleWishlist: (product) {
                            return _toggleWishlistProduct(
                              message: msg,
                              product: product,
                            );
                          },
                        );
                      },
                    ),
                  ),
                  _ChatInputBar(
                    controller: _controller,
                    onSend: () => _sendMessage(),
                    selectedAnalysis: _selectedAnalysis,
                    pickedImages: _pickedImages,
                    onSelectAnalysis: _openAnalysisMenu,
                    onPickImage: _pickImageForAnalysis,
                    onRemoveImage: _removePickedImage,
                    showAnalysisPanel: _showAnalysisPanel,
                    onShowPhotoGuide: _showPhotoGuide,
                    analysisButtonKey: _analysisButtonKey,
                    isSending: _isSending,
                  ),
                ],
              ),
            ),
          ),
          if (_isHistoryPanelOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeHistoryPanel,
                child: Container(
                  color: Colors.black.withOpacity(0.10),
                ),
              ),
            ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            top: 0,
            bottom: 0,
            right: _isHistoryPanelOpen ? 0 : -270,
            child: IgnorePointer(
              ignoring: !_isHistoryPanelOpen,
              child: SafeArea(
                child: Container(
                  width: 250,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 18,
                        offset: Offset(-4, 0),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                '최근 채팅',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF9AA08F),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: _toggleHistoryDeleteMode,
                              child: Text(
                                _isHistoryDeleteMode ? '취소' : '지우기',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFD96A8A),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: _isHistoryLoading
                            ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF8BC53F),
                          ),
                        )
                            : _chatHistory.isEmpty
                            ? const Center(
                          child: Text(
                            '아직 저장된 채팅이 없어요.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF8A8A8A),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                            : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                            12,
                            0,
                            12,
                            12,
                          ),
                          itemCount: _chatHistory.length,
                          separatorBuilder: (_, __) =>
                          const SizedBox(height: 6),
                          itemBuilder: (context, index) {
                            final session = _chatHistory[index];

                            return _HistoryChatTile(
                              title: session.title,
                              dateText:
                              _formatHistoryDate(session.updatedAt),
                              deleteMode: _isHistoryDeleteMode,
                              selected: _selectedHistoryIds
                                  .contains(session.roomId),
                              onCheckTap: () => _toggleHistorySelection(
                                session.roomId,
                              ),
                              onTap: () async {
                                if (_isHistoryDeleteMode) {
                                  _toggleHistorySelection(
                                    session.roomId,
                                  );
                                  return;
                                }

                                await _loadMessagesForRoom(
                                  session.roomId,
                                );
                                if (mounted) {
                                  _closeHistoryPanel();
                                }
                              },
                            );
                          },
                        ),
                      ),
                      if (_isHistoryDeleteMode)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: _toggleHistoryDeleteMode,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF4F6F0),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Text(
                                      '취소',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF666666),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: GestureDetector(
                                  onTap: _deleteSelectedHistory,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD96A8A),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Text(
                                      '삭제 (${_selectedHistoryIds.length})',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryChatTile extends StatelessWidget {
  final String title;
  final String dateText;
  final VoidCallback onTap;
  final bool deleteMode;
  final bool selected;
  final VoidCallback? onCheckTap;

  const _HistoryChatTile({
    required this.title,
    required this.dateText,
    required this.onTap,
    this.deleteMode = false,
    this.selected = false,
    this.onCheckTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 35,
              height: 35,
              child: Image.asset(
                'assets/images/chat.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF444444),
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (deleteMode)
              GestureDetector(
                onTap: onCheckTap,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF8BC53F)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF8BC53F)
                          : const Color(0xFFCFCFCF),
                      width: 1.6,
                    ),
                  ),
                  child: selected
                      ? const Icon(
                    Icons.check,
                    size: 15,
                    color: Colors.white,
                  )
                      : null,
                ),
              )
            else
              Text(
                dateText,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFFB0B0B0),
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final int? messageId;
  final List<Uint8List> images;
  final List<RecommendedProduct> recommendedProducts;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.messageId,
    this.images = const [],
    this.recommendedProducts = const [],
  });
}

class ChatSession {
  final int roomId;
  final String title;
  final String preview;
  final DateTime updatedAt;

  ChatSession({
    required this.roomId,
    required this.title,
    required this.preview,
    required this.updatedAt,
  });
}

enum AnalysisType {
  none,
  normal,
  detail,
  ingredient,
  personalColor,
}

extension AnalysisTypeX on AnalysisType {
  String get label {
    switch (this) {
      case AnalysisType.normal:
        return '빠른 분석';
      case AnalysisType.detail:
        return '정밀 분석';
      case AnalysisType.ingredient:
        return '성분 분석';
      case AnalysisType.personalColor:
        return '퍼스널 컬러 진단';
      case AnalysisType.none:
        return '분석 선택';
    }
  }

  int get maxImages {
    switch (this) {
      case AnalysisType.normal:
        return 1;
      case AnalysisType.detail:
        return 3;
      case AnalysisType.ingredient:
        return 1;
      case AnalysisType.personalColor:
        return 1;
      case AnalysisType.none:
        return 0;
    }
  }

  List<String> get slotLabels {
    switch (this) {
      case AnalysisType.normal:
        return ['정면 얼굴'];
      case AnalysisType.detail:
        return ['정면 얼굴', '좌측 얼굴', '우측 얼굴'];
      case AnalysisType.ingredient:
        return ['성분 사진'];
      case AnalysisType.personalColor:
        return ['정면 얼굴'];
      case AnalysisType.none:
        return [];
    }
  }

  String get helperText {
    switch (this) {
      case AnalysisType.normal:
        return '빠른 분석 · 정면 1장 업로드';
      case AnalysisType.detail:
        return '정밀 분석 · 정면/좌측/우측 3장 업로드';
      case AnalysisType.ingredient:
        return '성분 분석 · 1장 업로드';
      case AnalysisType.personalColor:
        return '퍼스널 컬러 진단 · 정면 1장 업로드';
      case AnalysisType.none:
        return '';
    }
  }
}

class PickedChatImage {
  final XFile file;
  final Uint8List bytes;

  PickedChatImage({
    required this.file,
    required this.bytes,
  });
}

class _ChatTopBar extends StatelessWidget {
  final VoidCallback onHistoryTap;

  const _ChatTopBar({
    required this.onHistoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 42,
            height: 42,
            child: Image.asset(
              'assets/images/chat.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'AI 피부 분석 챗봇',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF222222),
              ),
            ),
          ),
          IconButton(
            onPressed: onHistoryTap,
            icon: Image.asset(
              'assets/images/save.png',
              width: 43,
              height: 43,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyChatView extends StatelessWidget {
  final List<String> suggestions;
  final ValueChanged<String> onSuggestionTap;

  const _EmptyChatView({
    required this.suggestions,
    required this.onSuggestionTap,
  });

  Widget _buildSuggestionChip(String text) {
    return TextButton(
      onPressed: () => onSuggestionTap(text),
      style: TextButton.styleFrom(
        backgroundColor: const Color(0xFFEAF4D7),
        foregroundColor: const Color(0xFF6FA52D),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: const StadiumBorder(),
        elevation: 0,
        shadowColor: Colors.transparent,
        textStyle: const TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
        ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w800,
          color: Color(0xFF6FA52D),
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        children: [
          const SizedBox(height: 30),
          Image.asset(
            'assets/images/chat_text_logo.png',
            width: 300,
            height: 130,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 8),
          const Text(
            '내 피부를 위한 AI 도우미',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w900,
              color: Color(0xFF79B52F),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            '피부 고민을 입력하거나 추천 질문을 눌러보세요.\n제품 성분, 피부 타입, 트러블 케어를 도와드릴게요.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.2,
              height: 1.6,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(height: 28),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: suggestions.map(_buildSuggestionChip).toList(),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool Function(RecommendedProduct product) isProductSaved;
  final Future<void> Function(RecommendedProduct product) onToggleWishlist;

  const _MessageBubble({
    required this.message,
    required this.isProductSaved,
    required this.onToggleWishlist,
  });

  @override
  Widget build(BuildContext context) {
    final bool isUser = message.isUser;
    final bool hasText = message.text.trim().isNotEmpty;
    final bool hasProducts = !isUser && message.recommendedProducts.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
        isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            SizedBox(
              width: 34,
              height: 34,
              child: Image.asset(
                'assets/images/chat_avatar.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (message.images.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment:
                    isUser ? WrapAlignment.end : WrapAlignment.start,
                    children: message.images.map((imageBytes) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.memory(
                          imageBytes,
                          width: 110,
                          height: 110,
                          fit: BoxFit.cover,
                        ),
                      );
                    }).toList(),
                  ),
                if (message.images.isNotEmpty && (hasText || hasProducts))
                  const SizedBox(height: 8),
                if (hasText || hasProducts)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFF8BC53F) : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: isUser
                          ? []
                          : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (hasText)
                          isUser
                              ? Text(
                            message.text,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                              : MarkdownBody(
                            data: message.text,
                            selectable: false,
                            onTapLink: (text, href, title) async {
                              if (href == null) return;
                              final uri = Uri.tryParse(href);
                              if (uri == null) return;

                              final opened = await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );

                              if (!opened) {
                                debugPrint('링크를 열 수 없습니다: $href');
                              }
                            },
                            styleSheet: MarkdownStyleSheet(
                              p: const TextStyle(
                                fontSize: 14,
                                height: 1.5,
                                color: Color(0xFF222222),
                                fontWeight: FontWeight.w600,
                              ),
                              h1: const TextStyle(
                                fontSize: 18,
                                height: 1.5,
                                color: Color(0xFF222222),
                                fontWeight: FontWeight.w800,
                              ),
                              h2: const TextStyle(
                                fontSize: 17,
                                height: 1.5,
                                color: Color(0xFF222222),
                                fontWeight: FontWeight.w800,
                              ),
                              h3: const TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                color: Color(0xFF222222),
                                fontWeight: FontWeight.w800,
                              ),
                              strong: const TextStyle(
                                fontSize: 14,
                                height: 1.5,
                                color: Color(0xFF222222),
                                fontWeight: FontWeight.w800,
                              ),
                              listBullet: const TextStyle(
                                fontSize: 14,
                                height: 1.5,
                                color: Color(0xFF222222),
                                fontWeight: FontWeight.w600,
                              ),
                              a: const TextStyle(
                                fontSize: 14,
                                height: 1.5,
                                color: Color(0xFF6E8E2E),
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        if (hasProducts) ...[
                          if (hasText) const SizedBox(height: 14),
                          const Text(
                            '🛒 올리브영 구매 링크',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2F2F2F),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...message.recommendedProducts.map((product) {
                            final isSaved = isProductSaved(product);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () => onToggleWishlist(product),
                                    child: Container(
                                      width: 34,
                                      height: 34,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0xFFD9D9D9),
                                        ),
                                        color: Colors.white,
                                      ),
                                      child: Icon(
                                        isSaved
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        size: 18,
                                        color: isSaved
                                            ? const Color(0xFF8BC34A)
                                            : const Color(0xFFB0B0B0),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: product.url.trim().isEmpty
                                          ? null
                                          : () async {
                                        final uri =
                                        Uri.tryParse(product.url);
                                        if (uri == null) return;

                                        if (!await launchUrl(
                                          uri,
                                          mode: LaunchMode
                                              .externalApplication,
                                        )) {
                                          debugPrint(
                                            '링크를 열 수 없습니다: ${product.url}',
                                          );
                                        }
                                      },
                                      style: OutlinedButton.styleFrom(
                                        alignment: Alignment.centerLeft,
                                        backgroundColor:
                                        const Color(0xFFF6FAEC),
                                        side: const BorderSide(
                                          color: Color(0xFFB9D989),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 12,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              product.title,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF6E8E2E),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          const Icon(
                                            Icons.open_in_new,
                                            size: 16,
                                            color: Color(0xFF6E8E2E),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatLogoVideo extends StatefulWidget {
  final String assetPath;
  final double width;
  final double height;

  const ChatLogoVideo({
    super.key,
    required this.assetPath,
    this.width = 280,
    this.height = 140,
  });

  @override
  State<ChatLogoVideo> createState() => _ChatLogoVideoState();
}

class _ChatLogoVideoState extends State<ChatLogoVideo> {
  VideoPlayerController? _controller;
  bool _ready = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      final controller = VideoPlayerController.asset(widget.assetPath);
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(0);
      await controller.play();

      if (!mounted) {
        controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _ready = true;
        _failed = false;
      });
    } catch (e) {
      debugPrint('ChatLogoVideo 초기화 실패: $e');

      if (mounted) {
        setState(() {
          _failed = true;
          _ready = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: _failed
          ? const Center(
        child: Icon(
          Icons.chat_bubble_rounded,
          color: Color(0xFF8BC53F),
          size: 70,
        ),
      )
          : !_ready || _controller == null
          ? const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            color: Color(0xFF8BC53F),
          ),
        ),
      )
          : Center(
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: _controller!.value.size.width,
              height: _controller!.value.size.height,
              child: VideoPlayer(_controller!),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final AnalysisType selectedAnalysis;
  final List<PickedChatImage> pickedImages;
  final VoidCallback onSelectAnalysis;
  final VoidCallback onPickImage;
  final ValueChanged<int> onRemoveImage;
  final bool showAnalysisPanel;
  final VoidCallback? onShowPhotoGuide;
  final GlobalKey analysisButtonKey;
  final bool isSending;

  const _ChatInputBar({
    required this.controller,
    required this.onSend,
    required this.selectedAnalysis,
    required this.pickedImages,
    required this.onSelectAnalysis,
    required this.onPickImage,
    required this.onRemoveImage,
    required this.showAnalysisPanel,
    required this.analysisButtonKey,
    required this.isSending,
    this.onShowPhotoGuide,
  });

  @override
  Widget build(BuildContext context) {
    final maxImages = selectedAnalysis.maxImages;
    final labels = selectedAnalysis.slotLabels;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
          child: Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              key: analysisButtonKey,
              onTap: onSelectAnalysis,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7FBEF).withOpacity(0.92),
                  border: Border.all(
                    color: const Color(0xFFB9D88A),
                    width: 1.6,
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      selectedAnalysis.label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF7DAF35),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_up_rounded,
                      size: 18,
                      color: Color(0xFF7DAF35),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.94),
            border: Border(
              top: BorderSide(
                color: Colors.black.withOpacity(0.05),
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showAnalysisPanel && selectedAnalysis != AnalysisType.none) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            selectedAnalysis.helperText,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF93A08A),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: onShowPhotoGuide,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF1F5),
                            border: Border.all(
                              color: const Color(0xFFF3B6C6),
                              width: 1.6,
                            ),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            '촬영 시 주의사항',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFD96A8A),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(maxImages, (index) {
                      final hasImage = index < pickedImages.length;

                      return _UploadSlot(
                        width: maxImages == 1 ? 112 : 94,
                        height: maxImages == 1 ? 112 : 106,
                        label: labels[index],
                        imageBytes: hasImage ? pickedImages[index].bytes : null,
                        onTap: hasImage ? null : onPickImage,
                        onRemove: hasImage ? () => onRemoveImage(index) : null,
                      );
                    }),
                  ),
                ),
              ],
              Padding(
                padding: EdgeInsets.fromLTRB(
                  14,
                  showAnalysisPanel && selectedAnalysis != AnalysisType.none
                      ? 12
                      : 14,
                  14,
                  14,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F6F8),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: TextField(
                          controller: controller,
                          minLines: 1,
                          maxLines: 4,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) {
                            if (!isSending) {
                              onSend();
                            }
                          },
                          decoration: const InputDecoration(
                            hintText: '지금, AI와 피부 고민을 나눠보세요.',
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              color: Color(0xFF9AA1AD),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: isSending ? null : onSend,
                      child: Opacity(
                        opacity: isSending ? 0.6 : 1,
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: const Color(0xFF8BC53F),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: isSending
                              ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                              : const Icon(
                            Icons.arrow_upward_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UploadSlot extends StatelessWidget {
  final double width;
  final double height;
  final String label;
  final Uint8List? imageBytes;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const _UploadSlot({
    required this.width,
    required this.height,
    required this.label,
    required this.imageBytes,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageBytes != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: width,
            height: height,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFFFAFCF6),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFD6E8B9),
                width: 1.6,
              ),
            ),
            child: hasImage
                ? Stack(
              fit: StackFit.expand,
              children: [
                Image.memory(
                  imageBytes!,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            )
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.add_photo_alternate_outlined,
                  color: Color(0xFF9CC75D),
                  size: 28,
                ),
                SizedBox(height: 6),
                Text(
                  '업로드',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF9CC75D),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF5B5B5B),
          ),
        ),
      ],
    );
  }
}

class PhotoGuideItem {
  final String imagePath;
  final String title;
  final String description;

  const PhotoGuideItem({
    required this.imagePath,
    required this.title,
    required this.description,
  });
}

class _PhotoGuideDialog extends StatefulWidget {
  final AnalysisType analysisType;

  const _PhotoGuideDialog({
    required this.analysisType,
  });

  @override
  State<_PhotoGuideDialog> createState() => _PhotoGuideDialogState();
}

class _PhotoGuideDialogState extends State<_PhotoGuideDialog> {
  late final PageController _pageController;
  int _currentPage = 0;

  List<PhotoGuideItem> get _items {
    switch (widget.analysisType) {
      case AnalysisType.normal:
      case AnalysisType.detail:
      case AnalysisType.personalColor:
        return const [
          PhotoGuideItem(
            imagePath: 'assets/images/photo_guide_1.png',
            title: '정면 얼굴 촬영',
            description: '',
          ),
          PhotoGuideItem(
            imagePath: 'assets/images/photo_guide_2.png',
            title: '좌측 얼굴 촬영',
            description: '',
          ),
          PhotoGuideItem(
            imagePath: 'assets/images/photo_guide_3.png',
            title: '우측 얼굴 촬영',
            description: '',
          ),
        ];
      case AnalysisType.ingredient:
        return const [
          PhotoGuideItem(
            imagePath: 'assets/images/ingredient_guide_1.png',
            title: '전성분표 전체 촬영',
            description: '',
          ),
          PhotoGuideItem(
            imagePath: 'assets/images/ingredient_guide_2.png',
            title: '글자가 선명하게 보이게 촬영',
            description: '',
          ),
          PhotoGuideItem(
            imagePath: 'assets/images/ingredient_guide_3.png',
            title: '빛 반사 없이 촬영',
            description: '',
          ),
        ];
      case AnalysisType.none:
        return const [];
    }
  }

  String get _guideCaption {
    switch (widget.analysisType) {
      case AnalysisType.normal:
      case AnalysisType.detail:
      case AnalysisType.personalColor:
        return '설명 내용을 참고해서 촬영해주세요.';
      case AnalysisType.ingredient:
        return '전성분표가 잘리지 않게, 글자가 선명하게 보이도록 촬영해주세요.';
      case AnalysisType.none:
        return '';
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    if (index < 0 || index >= _items.length) return;

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildDot(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 10 : 8,
      height: isActive ? 10 : 8,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF85C13D) : const Color(0xFFD7E5BF),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _arrowButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.14),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 20,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    '촬영 가이드',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF222222),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F6F0),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 20,
                      color: Color(0xFF555555),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _guideCaption,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: Color(0xFF7B7B7B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 280,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: items.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final item = items[index];

                      return Column(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: Container(
                                width: double.infinity,
                                color: const Color(0xFFF7FAF1),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Image.asset(
                                    item.imagePath,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: const Color(0xFFF7FAF1),
                                        child: Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.photo_library_outlined,
                                              size: 44,
                                              color: Color(0xFF9CC75D),
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              item.title,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w800,
                                                color: Color(0xFF6FAA29),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  if (_currentPage > 0)
                    Positioned(
                      left: 8,
                      top: 125,
                      child: _arrowButton(
                        icon: Icons.chevron_left,
                        onTap: () => _goToPage(_currentPage - 1),
                      ),
                    ),
                  if (_currentPage < items.length - 1)
                    Positioned(
                      right: 8,
                      top: 125,
                      child: _arrowButton(
                        icon: Icons.chevron_right,
                        onTap: () => _goToPage(_currentPage + 1),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                items.length,
                    (index) => _buildDot(index == _currentPage),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8BC53F),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Text(
                    '확인',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalysisPopupCard extends StatelessWidget {
  final AnalysisType selectedAnalysis;

  const _AnalysisPopupCard({
    required this.selectedAnalysis,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              decoration: const BoxDecoration(
                color: Color(0xFFE7F0CF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: const Text(
                '분석 선택',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF6E9E28),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                children: [
                  _AnalysisPopupItem(
                    title: '빠른 분석',
                    description: '얼굴 정면 1장으로 빠른 피부 상태 분석',
                    selected: selectedAnalysis == AnalysisType.normal,
                    onTap: () => Navigator.pop(context, AnalysisType.normal),
                  ),
                  const SizedBox(height: 6),
                  _AnalysisPopupItem(
                    title: '정밀 분석',
                    description: '정면·좌·우측 3장으로 정밀 피부 분석',
                    selected: selectedAnalysis == AnalysisType.detail,
                    onTap: () => Navigator.pop(context, AnalysisType.detail),
                  ),
                  const SizedBox(height: 6),
                  _AnalysisPopupItem(
                    title: '성분 분석',
                    description: '화장품 성분표 1장으로 성분 안전성 분석',
                    selected: selectedAnalysis == AnalysisType.ingredient,
                    onTap: () => Navigator.pop(context, AnalysisType.ingredient),
                  ),
                  const SizedBox(height: 6),
                  _AnalysisPopupItem(
                    title: '퍼스널 컬러 진단',
                    description: '정면 얼굴 1장으로 어울리는 퍼스널 컬러 분석',
                    selected: selectedAnalysis == AnalysisType.personalColor,
                    onTap: () =>
                        Navigator.pop(context, AnalysisType.personalColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalysisPopupItem extends StatelessWidget {
  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  const _AnalysisPopupItem({
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF6FAEE) : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFF8BC53F) : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected
                        ? const Color(0xFF8BC53F)
                        : const Color(0xFFC7D3AE),
                    width: 1.8,
                  ),
                  boxShadow: selected
                      ? [
                    BoxShadow(
                      color: const Color(0xFF8BC53F).withOpacity(0.18),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                      : null,
                ),
                child: Icon(
                  selected ? Icons.check_rounded : Icons.circle,
                  size: selected ? 14 : 8,
                  color: selected ? Colors.white : const Color(0xFF9BB56A),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: selected
                          ? const Color(0xFF6EA92A)
                          : const Color(0xFF2F3A2F),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12.5,
                      height: 1.35,
                      color: Color(0xFF6F7785),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecommendedProductSection extends StatelessWidget {
  final List<RecommendedProduct> products;
  final bool Function(RecommendedProduct product) isProductSaved;
  final Future<void> Function(RecommendedProduct product) onToggleWishlist;
  final void Function(String url)? onOpenUrl;

  const RecommendedProductSection({
    super.key,
    required this.products,
    required this.isProductSaved,
    required this.onToggleWishlist,
    this.onOpenUrl,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        const Divider(),
        const SizedBox(height: 10),
        const Text(
          '🛒 올리브영 구매 링크',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2F3A2F),
          ),
        ),
        const SizedBox(height: 10),
        ...products.map((product) {
          final isSaved = isProductSaved(product);

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => onToggleWishlist(product),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFD8D8D8),
                      ),
                      color: Colors.white,
                    ),
                    child: Icon(
                      isSaved ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                      color: isSaved
                          ? const Color(0xFF9BCB3C)
                          : const Color(0xFFB0B0B0),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: product.url.trim().isEmpty
                        ? null
                        : () {
                      if (onOpenUrl != null) {
                        onOpenUrl!(product.url);
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      side: const BorderSide(
                        color: Color(0xFFB8D87B),
                      ),
                      backgroundColor: const Color(0xFFF7FBEF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.title,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B8E23),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.open_in_new,
                          size: 16,
                          color: Color(0xFF6B8E23),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

