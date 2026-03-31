import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../models/skin_analysis_result.dart';
import 'api_config.dart';
import 'auth_service.dart';

class AnalysisUploadFile {
  final Uint8List bytes;
  final String fileName;

  const AnalysisUploadFile({
    required this.bytes,
    required this.fileName,
  });
}

class ApiService {
  static const String _wishlistPath = '/wishlist';
  static const String _chatRoomsPath = '/chats';
  static const String _usersMePath = '/users/me';
  static const String _analysisPath = '/analysis';
  static const String _uploadPath = '/upload';
  static const String _skinAnalysisSavePath = '/skin-analysis/save';
  static const String _qnaPath = '/qna';

  static Future<Map<String, String>> _authJsonHeaders() async {
    final headers = await AuthService.authHeaders();
    return {
      ...headers,
      'Accept': 'application/json',
    };
  }

  static Future<Map<String, String>> _authMultipartHeaders() async {
    final token = await AuthService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('로그인이 필요해요.');
    }

    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
  }

  static String _bodyText(http.Response response) {
    return utf8.decode(response.bodyBytes);
  }

  static dynamic _decodeBody(http.Response response) {
    final text = _bodyText(response).trim();
    if (text.isEmpty) return null;

    try {
      return jsonDecode(text);
    } catch (_) {
      return text;
    }
  }

  static Exception _error(String title, http.Response response) {
    return Exception(
      '$title\n'
          '상태코드: ${response.statusCode}\n'
          '응답: ${_bodyText(response)}',
    );
  }

  static List<dynamic> _normalizeList(dynamic data) {
    if (data is List) return data;

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);

      if (map['items'] is List) return List<dynamic>.from(map['items']);
      if (map['results'] is List) return List<dynamic>.from(map['results']);
      if (map['data'] is List) return List<dynamic>.from(map['data']);
      if (map['messages'] is List) return List<dynamic>.from(map['messages']);
      if (map['rooms'] is List) return List<dynamic>.from(map['rooms']);
      if (map['wishlist'] is List) return List<dynamic>.from(map['wishlist']);
    }

    return <dynamic>[];
  }

  static Map<String, dynamic> _normalizeMap(dynamic data) {
    if (data == null) return <String, dynamic>{};

    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    return <String, dynamic>{};
  }

  static Map<String, dynamic> _normalizeAnalysisMap(dynamic data) {
    if (data == null) return <String, dynamic>{};

    if (data is List) {
      if (data.isNotEmpty && data.first is Map) {
        return Map<String, dynamic>.from(data.first as Map);
      }
      return <String, dynamic>{};
    }

    if (data is Map) {
      final map = Map<String, dynamic>.from(data);

      if (map['item'] is Map) {
        return Map<String, dynamic>.from(map['item']);
      }

      if (map['result'] is Map) {
        return Map<String, dynamic>.from(map['result']);
      }

      if (map['data'] is Map) {
        return Map<String, dynamic>.from(map['data']);
      }

      if (map['items'] is List) {
        final items = List<dynamic>.from(map['items']);
        if (items.isNotEmpty && items.first is Map) {
          return Map<String, dynamic>.from(items.first as Map);
        }
      }

      if (map['results'] is List) {
        final results = List<dynamic>.from(map['results']);
        if (results.isNotEmpty && results.first is Map) {
          return Map<String, dynamic>.from(results.first as Map);
        }
      }

      return map;
    }

    return <String, dynamic>{};
  }

  static String _normalizedImageFileName(String originalName) {
    final lower = originalName.toLowerCase();

    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return originalName;
    }

    if (lower.endsWith('.png')) {
      return originalName;
    }

    final dotIndex = originalName.lastIndexOf('.');
    final baseName =
    dotIndex > 0 ? originalName.substring(0, dotIndex) : originalName;

    return '$baseName.jpg';
  }

  static MediaType _imageMediaTypeFromFileName(String fileName) {
    final lower = fileName.toLowerCase();

    if (lower.endsWith('.png')) {
      return MediaType('image', 'png');
    }

    return MediaType('image', 'jpeg');
  }

  static int _toInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is double) return value.round();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static DateTime _toDateTime(dynamic value) {
    return DateTime.tryParse(value?.toString() ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  static bool _isSkinAnalysisItem(
      Map<String, dynamic> item,
      int userId,
      ) {
    final modelType = item['model_type']?.toString() ?? '';
    final itemUserId = _toInt(item['user_id'], fallback: -1);
    final skinScore = item['skin_score'];

    final isSkinType = modelType == 'simple' || modelType == 'detailed';
    final hasScore = skinScore != null;

    return itemUserId == userId && isSkinType && hasScore;
  }

  static String? _extractAnalysisImageUrl(Map<String, dynamic> raw) {
    final imageValue = raw['image_url'];

    if (imageValue is List && imageValue.isNotEmpty) {
      final first = imageValue.first?.toString().trim();
      if (first != null && first.isNotEmpty) return first;
    }

    if (imageValue is String && imageValue.trim().isNotEmpty) {
      return imageValue.trim();
    }

    return null;
  }

  static int _parseMetricValue(dynamic value) {
    if (value is int) return value.clamp(0, 100);
    if (value is double) return value.round().clamp(0, 100);

    if (value is String) {
      return (int.tryParse(value) ?? double.tryParse(value)?.round() ?? 0)
          .clamp(0, 100);
    }

    if (value is Map) {
      final score = value['score'] ?? value['value'] ?? value['percent'];
      return _parseMetricValue(score);
    }

    return 0;
  }

  static int _metricScore(
      Map<String, dynamic> analysisData,
      List<String> keys,
      ) {
    final nestedMetrics = analysisData['metrics'] is Map
        ? Map<String, dynamic>.from(analysisData['metrics'])
        : <String, dynamic>{};

    for (final key in keys) {
      if (analysisData.containsKey(key)) {
        final parsed = _parseMetricValue(analysisData[key]);
        if (parsed > 0) return parsed;
      }

      if (nestedMetrics.containsKey(key)) {
        final parsed = _parseMetricValue(nestedMetrics[key]);
        if (parsed > 0) return parsed;
      }
    }

    return 0;
  }

  static String _metricStatus(int score) {
    if (score >= 85) return '매우 좋음';
    if (score >= 70) return '양호';
    if (score >= 55) return '보통';
    if (score >= 40) return '약간';
    return '약함';
  }

  static String _deriveSkinType(
      List<dynamic> factors,
      Map<String, dynamic> analysisData,
      ) {
    final directType = analysisData['skin_type']?.toString().trim() ?? '';
    if (directType.isNotEmpty && directType.toLowerCase() != 'null') {
      return directType;
    }

    final detailType =
        analysisData['skin_type_detail']?.toString().trim() ?? '';
    if (detailType.isNotEmpty && detailType.toLowerCase() != 'null') {
      return detailType;
    }

    final text = factors.map((e) => e.toString()).join(' ');
    if (text.contains('복합')) return '복합성';
    if (text.contains('건조') || text.contains('보습')) return '건성';
    if (text.contains('유분') || text.contains('피지')) return '지성';
    if (text.contains('민감')) return '민감성';
    return '피부 분석 결과';
  }

  static String _deriveSummary(
      List<dynamic> factors,
      Map<String, dynamic> analysisData,
      ) {
    final summary = analysisData['summary']?.toString().trim() ?? '';
    if (summary.isNotEmpty && summary.toLowerCase() != 'null') {
      return summary;
    }

    if (factors.isNotEmpty) {
      return factors.map((e) => e.toString()).join(', ');
    }

    return '최근 피부 분석 결과예요.';
  }

  static List<dynamic> _extractFactors(Map<String, dynamic> raw) {
    final factorial = raw['factorial'];
    if (factorial is List) return factorial;

    final factors = raw['factors'];
    if (factors is List) return factors;

    return const [];
  }

  static List<Map<String, dynamic>> _buildSkinMetrics(
      Map<String, dynamic> analysisData,
      ) {
    final moistureScore =
    _metricScore(analysisData, ['moisture', 'hydration', 'water', '수분']);
    final elasticityScore =
    _metricScore(analysisData, ['elasticity', 'firmness', '탄력']);
    final wrinkleScore =
    _metricScore(analysisData, ['wrinkle', 'wrinkles', '주름']);
    final poreScore = _metricScore(analysisData, ['pore', 'pores', '모공']);
    final pigmentScore = _metricScore(
      analysisData,
      ['pigment', 'pigmentation', 'spot', '색소침착'],
    );

    return [
      {
        'title': '수분',
        'score': moistureScore,
        'status': _metricStatus(moistureScore),
        'color': '#5B84D7',
        'icon': 'water',
      },
      {
        'title': '탄력',
        'score': elasticityScore,
        'status': _metricStatus(elasticityScore),
        'color': '#6EC39A',
        'icon': 'elasticity',
      },
      {
        'title': '주름',
        'score': wrinkleScore,
        'status': _metricStatus(wrinkleScore),
        'color': '#F0A86B',
        'icon': 'wrinkle',
      },
      {
        'title': '모공',
        'score': poreScore,
        'status': _metricStatus(poreScore),
        'color': '#9C6BC8',
        'icon': 'pore',
      },
      {
        'title': '색소침착',
        'score': pigmentScore,
        'status': _metricStatus(pigmentScore),
        'color': '#E06AA1',
        'icon': 'pigment',
      },
    ];
  }

  static Map<String, dynamic> _mapAnalysisItemToUiJson(
      Map<String, dynamic> raw,
      ) {
    final factors = _extractFactors(raw);
    final analysisData = raw['analysis_data'] is Map
        ? Map<String, dynamic>.from(raw['analysis_data'])
        : <String, dynamic>{};

    return <String, dynamic>{
      'analysis_id': _toInt(raw['analysis_id']),
      'analyzed_at': raw['created_at']?.toString() ?? '',
      'overall_score': _toInt(raw['skin_score']),
      'skin_type': _deriveSkinType(factors, analysisData),
      'summary': _deriveSummary(factors, analysisData),
      'analysis_image_url': _extractAnalysisImageUrl(raw),
      'metrics': _buildSkinMetrics(analysisData),
      'previous_analysis': null,
    };
  }

  static Future<Map<String, dynamic>> getMe() async {
    final uri = ApiConfig.uri(_usersMePath);
    final headers = await _authJsonHeaders();

    final response = await http.get(uri, headers: headers);

    print('GET ME URI: $uri');
    print('GET ME STATUS: ${response.statusCode}');
    print('GET ME BODY: ${_bodyText(response)}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = _decodeBody(response);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
      return <String, dynamic>{};
    }

    throw _error('내 정보 조회 실패', response);
  }

  static Future<SkinAnalysisResult> fetchLatestSkinAnalysis(int userId) async {
    final uri = ApiConfig.uri(_analysisPath);
    final headers = await _authJsonHeaders();

    final response = await http.get(uri, headers: headers);

    print('SKIN ANALYSIS URI: $uri');
    print('SKIN ANALYSIS STATUS: ${response.statusCode}');
    print('SKIN ANALYSIS BODY: ${_bodyText(response)}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _error('피부 분석 결과 조회 실패', response);
    }

    final decoded = _decodeBody(response);
    final items = _normalizeList(decoded)
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    final skinItems =
    items.where((item) => _isSkinAnalysisItem(item, userId)).toList();

    if (skinItems.isEmpty) {
      throw Exception('저장된 피부 분석 결과가 없어요.');
    }

    skinItems.sort((a, b) {
      return _toDateTime(b['created_at']).compareTo(_toDateTime(a['created_at']));
    });

    final currentMapped = _mapAnalysisItemToUiJson(skinItems[0]);

    if (skinItems.length > 1) {
      currentMapped['previous_analysis'] =
          _mapAnalysisItemToUiJson(skinItems[1]);
    }

    return SkinAnalysisResult.fromJson(currentMapped);
  }

  static Future<List<dynamic>> getWishlist() async {
    final uri = ApiConfig.uri(_wishlistPath);
    final headers = await _authJsonHeaders();

    final response = await http.get(uri, headers: headers);

    print('GET WISHLIST URI: $uri');
    print('GET WISHLIST STATUS: ${response.statusCode}');
    print('GET WISHLIST BODY: ${_bodyText(response)}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _normalizeList(_decodeBody(response));
    }

    throw _error('위시리스트 조회 실패', response);
  }

  static Future<List<SkinAnalysisResult>> fetchSkinAnalysisHistory(
      int userId,
      ) async {
    final uri = ApiConfig.uri(_analysisPath);
    final headers = await _authJsonHeaders();

    final response = await http.get(uri, headers: headers);

    print('SKIN ANALYSIS HISTORY URI: $uri');
    print('SKIN ANALYSIS HISTORY STATUS: ${response.statusCode}');
    print('SKIN ANALYSIS HISTORY BODY: ${_bodyText(response)}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _error('피부 분석 이력 조회 실패', response);
    }

    final decoded = _decodeBody(response);
    final items = _normalizeList(decoded)
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    final skinItems = items.where((item) => _isSkinAnalysisItem(item, userId)).toList();

    if (skinItems.isEmpty) {
      throw Exception('저장된 피부 분석 결과가 없어요.');
    }

    skinItems.sort((a, b) {
      return _toDateTime(b['created_at']).compareTo(_toDateTime(a['created_at']));
    });

    return skinItems
        .map((item) => SkinAnalysisResult.fromJson(_mapAnalysisItemToUiJson(item)))
        .toList();
  }

  static Future<Map<String, dynamic>> addWishlist({
    int? userId,
    String? title,
    String? name,
    String? productName,
    String? url,
    String? link,
    String? productUrl,
    String source = 'chatbot',
    String? imageUrl,
    int? productId,
    String? productVectorId,
    int? messageId,
    String? productDescription,
  }) async {
    final resolvedTitle = title ?? name ?? productName ?? '';
    final resolvedUrl = url ?? link ?? productUrl ?? '';

    final uri = ApiConfig.uri(_wishlistPath);
    final headers = await _authJsonHeaders();

    final body = <String, dynamic>{
      'title': resolvedTitle,
      'name': resolvedTitle,
      'product_name': resolvedTitle,
      'url': resolvedUrl,
      'link': resolvedUrl,
      'product_url': resolvedUrl,
      'source': source,
      if (userId != null) 'user_id': userId,
      if (imageUrl != null && imageUrl.isNotEmpty) 'image_url': imageUrl,
      if (productId != null) 'product_id': productId,
      if (productVectorId != null && productVectorId.isNotEmpty)
        'product_vector_id': productVectorId,
      if (messageId != null) 'message_id': messageId,
      if (productDescription != null && productDescription.isNotEmpty)
        'product_description': productDescription,
    };

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    print('ADD WISHLIST URI: $uri');
    print('ADD WISHLIST STATUS: ${response.statusCode}');
    print('ADD WISHLIST BODY: ${_bodyText(response)}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = _decodeBody(response);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
      return Map<String, dynamic>.from(body);
    }

    throw _error('위시리스트 추가 실패', response);
  }

  static Future<void> removeWishlist(dynamic wishId) async {
    final uri = ApiConfig.uri('$_wishlistPath/$wishId');
    final headers = await _authJsonHeaders();

    final response = await http.delete(uri, headers: headers);

    print('DELETE WISHLIST URI: $uri');
    print('DELETE WISHLIST STATUS: ${response.statusCode}');
    print('DELETE WISHLIST BODY: ${_bodyText(response)}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw _error('위시리스트 삭제 실패', response);
  }

  static Future<List<dynamic>> getChatRooms() async {
    final uri = ApiConfig.uri(_chatRoomsPath);
    final headers = await _authJsonHeaders();

    final response = await http.get(uri, headers: headers);

    print('GET CHAT ROOMS URI: $uri');
    print('GET CHAT ROOMS STATUS: ${response.statusCode}');
    print('GET CHAT ROOMS BODY: ${_bodyText(response)}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _normalizeList(_decodeBody(response));
    }

    throw _error('채팅방 목록 조회 실패', response);
  }

  static Future<Map<String, dynamic>> createChatRoom({
    String? title,
    String? name,
    String? initialMessage,
  }) async {
    final uri = ApiConfig.uri(_chatRoomsPath);
    final headers = await _authJsonHeaders();

    final body = <String, dynamic>{
      if (title != null && title.isNotEmpty) 'title': title,
      if (name != null && name.isNotEmpty) 'name': name,
      if (initialMessage != null && initialMessage.isNotEmpty)
        'initial_message': initialMessage,
    };

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    print('CREATE CHAT ROOM URI: $uri');
    print('CREATE CHAT ROOM STATUS: ${response.statusCode}');
    print('CREATE CHAT ROOM BODY: ${_bodyText(response)}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = _decodeBody(response);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
      return <String, dynamic>{};
    }

    throw _error('채팅방 생성 실패', response);
  }

  static Future<List<dynamic>> getChatMessages(int roomId) async {
    final uri = ApiConfig.uri('$_chatRoomsPath/$roomId/messages');
    final headers = await _authJsonHeaders();

    final response = await http.get(uri, headers: headers);

    print('GET CHAT MESSAGES URI: $uri');
    print('GET CHAT MESSAGES STATUS: ${response.statusCode}');
    print('GET CHAT MESSAGES BODY: ${_bodyText(response)}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _normalizeList(_decodeBody(response));
    }

    throw _error('채팅 메시지 조회 실패', response);
  }

  static Future<void> deleteChatRoom(int roomId) async {
    final uri = ApiConfig.uri('$_chatRoomsPath/$roomId');
    final headers = await _authJsonHeaders();

    final response = await http.delete(uri, headers: headers);

    print('DELETE CHAT ROOM URI: $uri');
    print('DELETE CHAT ROOM STATUS: ${response.statusCode}');
    print('DELETE CHAT ROOM BODY: ${_bodyText(response)}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw _error('채팅방 삭제 실패', response);
  }

  static Future<String> uploadAnalysisImage({
    required Uint8List imageBytes,
    required String fileName,
    required String analysisType,
  }) async {
    final baseUri = ApiConfig.uri(_uploadPath);
    final uri = baseUri.replace(
      queryParameters: {
        ...baseUri.queryParameters,
        'analysis_type': analysisType,
      },
    );

    final safeFileName = _normalizedImageFileName(fileName);
    final mediaType = _imageMediaTypeFromFileName(safeFileName);

    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(await _authMultipartHeaders())
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: safeFileName,
          contentType: mediaType,
        ),
      );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print('UPLOAD ANALYSIS IMAGE URI: $uri');
    print('UPLOAD ANALYSIS IMAGE FILE: $safeFileName');
    print('UPLOAD ANALYSIS IMAGE TYPE: $mediaType');
    print('UPLOAD ANALYSIS IMAGE STATUS: ${response.statusCode}');
    print('UPLOAD ANALYSIS IMAGE BODY: ${_bodyText(response)}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _error('이미지 업로드 실패', response);
    }

    final decoded = _decodeBody(response);

    if (decoded is Map && decoded['url'] != null) {
      return decoded['url'].toString();
    }

    if (decoded is String && decoded.trim().isNotEmpty) {
      return decoded.trim();
    }

    throw Exception('업로드 응답에서 이미지 URL을 찾지 못했어요.');
  }

  static Future<List<dynamic>> sendMessage({
    int? roomId,
    int? chatRoomId,
    String? message,
    String? text,
    String? content,
    String? prompt,
    String? modelType,
    Uint8List? imageBytes,
    String? imageFileName,
    String? imageContentType,
    List<String>? imageUrls,
  }) async {
    final resolvedRoomId = roomId ?? chatRoomId;
    final resolvedMessage = message ?? text ?? content ?? prompt ?? '';

    if (resolvedRoomId == null) {
      throw Exception('sendMessage: roomId(chatRoomId)가 필요해요.');
    }

    final uri = ApiConfig.uri('$_chatRoomsPath/$resolvedRoomId/messages');

    print('SEND MESSAGE URI: $uri');

    if (imageBytes == null) {
      final headers = await _authJsonHeaders();

      final body = <String, dynamic>{
        'chat_room_id': resolvedRoomId,
        'role': 'user',
        'message': resolvedMessage,
        'text': resolvedMessage,
        'content': resolvedMessage,
        'prompt': resolvedMessage,
        if (modelType != null) 'model_type': modelType,
        if (imageUrls != null && imageUrls.isNotEmpty) 'image_url': imageUrls,
      };

      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );

      print('SEND MESSAGE STATUS: ${response.statusCode}');
      print('SEND MESSAGE BODY: ${_bodyText(response)}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return _normalizeList(_decodeBody(response));
      }

      throw _error('메시지 전송 실패', response);
    }

    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(await _authMultipartHeaders())
      ..fields['chat_room_id'] = resolvedRoomId.toString()
      ..fields['role'] = 'user'
      ..fields['message'] = resolvedMessage
      ..fields['text'] = resolvedMessage
      ..fields['content'] = resolvedMessage
      ..fields['prompt'] = resolvedMessage;

    if (modelType != null && modelType.isNotEmpty) {
      request.fields['model_type'] = modelType;
    }

    if (imageUrls != null && imageUrls.isNotEmpty) {
      request.fields['image_url'] = jsonEncode(imageUrls);
    }

    request.files.add(
      http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: imageFileName ?? 'image.jpg',
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print('SEND MESSAGE(MULTIPART) STATUS: ${response.statusCode}');
    print('SEND MESSAGE(MULTIPART) BODY: ${_bodyText(response)}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _normalizeList(_decodeBody(response));
    }

    throw _error('이미지 메시지 전송 실패', response);
  }

  static Future<Map<String, dynamic>> requestAnalysis({
    required String modelType,
    required List<AnalysisUploadFile> files,
    String? content,
  }) async {
    final uri = ApiConfig.uri(_analysisPath);

    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(await _authMultipartHeaders())
      ..fields['model_type'] = modelType;

    if (content != null && content.trim().isNotEmpty) {
      request.fields['content'] = content.trim();
    }

    if (modelType == 'detailed') {
      if (files.length != 3) {
        throw Exception('정밀 분석은 정면/좌/우 3장이 필요해요.');
      }

      request.files.add(
        http.MultipartFile.fromBytes(
          'front_image',
          files[0].bytes,
          filename: files[0].fileName,
        ),
      );
      request.files.add(
        http.MultipartFile.fromBytes(
          'left_image',
          files[1].bytes,
          filename: files[1].fileName,
        ),
      );
      request.files.add(
        http.MultipartFile.fromBytes(
          'right_image',
          files[2].bytes,
          filename: files[2].fileName,
        ),
      );
    } else {
      if (files.isEmpty) {
        throw Exception('이미지가 필요해요.');
      }

      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          files.first.bytes,
          filename: files.first.fileName,
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print('REQUEST ANALYSIS URI: $uri');
    print('REQUEST ANALYSIS STATUS: ${response.statusCode}');
    print('REQUEST ANALYSIS BODY: ${_bodyText(response)}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _normalizeAnalysisMap(_decodeBody(response));
    }

    throw _error('분석 요청 실패', response);
  }

  static Future<Map<String, dynamic>> getAnalysisDetail(int analysisId) async {
    final uri = ApiConfig.uri('$_analysisPath/$analysisId');
    final headers = await _authJsonHeaders();

    final response = await http.get(uri, headers: headers);

    print('GET ANALYSIS DETAIL URI: $uri');
    print('GET ANALYSIS DETAIL STATUS: ${response.statusCode}');
    print('GET ANALYSIS DETAIL BODY: ${_bodyText(response)}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _normalizeAnalysisMap(_decodeBody(response));
    }

    throw _error('분석 상세 조회 실패', response);
  }

  static Future<void> saveSkinAnalysisResult({
    required int userId,
    required int chatRoomId,
    required String frontImageUrl,
    required String leftImageUrl,
    required String rightImageUrl,
    required Map<String, dynamic> assistantMessage,
  }) async {
    final uri = ApiConfig.uri(_skinAnalysisSavePath);
    final authHeaders = await _authJsonHeaders();

    final response = await http.post(
      uri,
      headers: {
        ...authHeaders,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'user_id': userId,
        'chat_room_id': chatRoomId,
        'front_image_url': frontImageUrl,
        'left_image_url': leftImageUrl,
        'right_image_url': rightImageUrl,
        'assistant_message': assistantMessage,
      }),
    );

    print('SAVE SKIN ANALYSIS RESULT URI: $uri');
    print('SAVE SKIN ANALYSIS RESULT STATUS: ${response.statusCode}');
    print('SAVE SKIN ANALYSIS RESULT BODY: ${_bodyText(response)}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _error('피부 분석 결과 저장 실패', response);
    }
  }

  static Future<Map<String, dynamic>> saveAnalysis({
    required int userId,
    required String modelType,
    required int skinScore,
    required List<String> imageUrls,
    required List<String> factorial,
    required Map<String, dynamic> analysisData,
    required String accessToken,
  }) async {
    final uri = ApiConfig.uri(_analysisPath);

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'user_id': userId,
        'model_type': modelType,
        'skin_score': skinScore,
        'image_url': imageUrls,
        'factorial': factorial,
        'analysis_data': analysisData,
      }),
    );

    print('SAVE ANALYSIS URI: $uri');
    print('SAVE ANALYSIS STATUS: ${response.statusCode}');
    print('SAVE ANALYSIS BODY: ${_bodyText(response)}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _error('분석 결과 저장 실패', response);
    }

    final decoded = _decodeBody(response);
    return _normalizeMap(decoded);
  }

  static Future<Map<String, dynamic>> createQna({
    required String category,
    required String questionTitle,
    required String question,
  }) async {
    final headers = await AuthService.authHeaders();

    final response = await http.post(
      ApiConfig.uri(_qnaPath),
      headers: {
        ...headers,
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'category': category,
        'question_title': questionTitle,
        'question': question,
      }),
    );

    final decoded = utf8.decode(response.bodyBytes);

    print('CREATE QNA URI: ${ApiConfig.uri(_qnaPath)}');
    print('CREATE QNA STATUS: ${response.statusCode}');
    print('CREATE QNA BODY: $decoded');

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (decoded.trim().isEmpty) return <String, dynamic>{};
      return jsonDecode(decoded) as Map<String, dynamic>;
    }

    throw Exception('Q&A 등록 실패 (${response.statusCode}): $decoded');
  }
}