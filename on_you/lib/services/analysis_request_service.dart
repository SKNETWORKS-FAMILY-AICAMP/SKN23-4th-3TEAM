import 'dart:io';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

import '../services/api_service.dart';

class AnalysisRequestService {
  static Future<Map<String, dynamic>> runQuickAnalysisFromPath({
    required String imagePath,
    String userText = '피부 빠른 분석 해줘',
  }) async {
    final chatRoomId = await _createChatRoomId();

    final file = XFile(imagePath);
    final Uint8List bytes = await File(file.path).readAsBytes();

    final uploadedUrl = await ApiService.uploadAnalysisImage(
      imageBytes: bytes,
      fileName: file.name,
      analysisType: 'quick',
    );

    final responseList = await ApiService.sendMessage(
      chatRoomId: chatRoomId,
      content: userText,
      modelType: 'quick',
      imageBytes: null,
      imageFileName: null,
      imageUrls: [uploadedUrl],
    );

    final aiMessageMap = _extractAssistantMessage(responseList);

    return {
      'chat_room_id': chatRoomId,
      'assistant_message': aiMessageMap,
      'uploaded_urls': [uploadedUrl],
    };
  }

  static Future<Map<String, dynamic>> runDetailAnalysisFromPaths({
    required String frontPath,
    required String leftPath,
    required String rightPath,
    required int userId,
    String userText = '피부 정밀 분석 해줘',
  }) async {
    final room = await ApiService.createChatRoom();
    final chatRoomId = _toInt(room['chat_room_id'] ?? room['id']);

    if (chatRoomId == null) {
      throw Exception('채팅방 ID를 받지 못했어요.');
    }

    final files = [
      XFile(frontPath),
      XFile(leftPath),
      XFile(rightPath),
    ];

    final uploadedUrls = <String>[];

    for (final file in files) {
      final Uint8List bytes = await File(file.path).readAsBytes();

      final url = await ApiService.uploadAnalysisImage(
        imageBytes: bytes,
        fileName: file.name,
        analysisType: 'detailed',
      );

      uploadedUrls.add(url);
    }

    final responseList = await ApiService.sendMessage(
      chatRoomId: chatRoomId,
      content: userText,
      modelType: 'detailed',
      imageBytes: null,
      imageFileName: null,
      imageUrls: uploadedUrls,
    );

    final aiMessageMap = _extractAssistantMessage(responseList);

    await ApiService.saveSkinAnalysisResult(
      userId: userId,
      chatRoomId: chatRoomId,
      frontImageUrl: uploadedUrls[0],
      leftImageUrl: uploadedUrls[1],
      rightImageUrl: uploadedUrls[2],
      assistantMessage: aiMessageMap,
    );

    return {
      'chat_room_id': chatRoomId,
      'assistant_message': aiMessageMap,
      'uploaded_urls': uploadedUrls,
    };
  }

  static Future<Map<String, dynamic>> runIngredientAnalysisFromPath({
    required String imagePath,
    String userText = '이 화장품 성분표를 분석해줘',
  }) async {
    final chatRoomId = await _createChatRoomId();

    final file = XFile(imagePath);
    final Uint8List bytes = await File(file.path).readAsBytes();

    final uploadedUrl = await ApiService.uploadAnalysisImage(
      imageBytes: bytes,
      fileName: file.name,
      analysisType: 'ingredient',
    );

    final responseList = await ApiService.sendMessage(
      chatRoomId: chatRoomId,
      content: userText,
      modelType: 'ingredient',
      imageBytes: null,
      imageFileName: null,
      imageUrls: [uploadedUrl],
    );

    final aiMessageMap = _extractAssistantMessage(responseList);

    return {
      'chat_room_id': chatRoomId,
      'assistant_message': aiMessageMap,
      'uploaded_urls': [uploadedUrl],
    };
  }

  static Future<int> _createChatRoomId() async {
    final room = await ApiService.createChatRoom();
    final chatRoomId = _toInt(room['chat_room_id'] ?? room['id']);

    if (chatRoomId == null) {
      throw Exception('채팅방 ID를 받지 못했어요.');
    }

    return chatRoomId;
  }

  static Map<String, dynamic> _extractAssistantMessage(
      List<dynamic> responseList,
      ) {
    Map<String, dynamic>? aiMessageMap;

    for (final item in responseList) {
      if (item is Map<String, dynamic> && item['role'] == 'assistant') {
        aiMessageMap = item;
      }
    }

    if (aiMessageMap == null) {
      throw Exception('분석 응답을 받지 못했어요.');
    }

    return aiMessageMap;
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}