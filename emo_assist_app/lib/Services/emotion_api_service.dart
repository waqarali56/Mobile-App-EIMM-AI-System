// lib/Services/EmotionService.dart
import 'dart:io';
import 'package:emo_assist_app/Models/TextEmotionData.dart';

import '../Models/EmotionData.dart';
import '../Resources/api_client.dart';

class EmotionService {
  final ApiClient _apiClient = ApiClient();

  // In lib/Services/EmotionService.dart - Update analyzeText method
  Future<ApiResponse<TextEmotionData>> analyzeText(String text) async {
    print('📝 [EmotionService] Analyzing text: ${text.length} characters');

    try {
      final response = await _apiClient.post(
        '/predict_text',
        body: {'paragraph': text},
        fromJson: (json) {
          print('📝 [EmotionService] Raw JSON response: $json');
          return TextEmotionData.fromJson(json);
        },
      );

      if (response.success) {
        print('✅ [EmotionService] Text analysis successful');
        print(
            '✅ [EmotionService] Final emotion: ${response.data!.finalEmotion}');
        return ApiResponse.success(response.data!);
      } else {
        print('❌ [EmotionService] Text analysis failed: ${response.message}');
        return ApiResponse.error(response.message ?? 'Text analysis failed');
      }
    } catch (e) {
      print('💥 [EmotionService] Exception: $e');
      return ApiResponse.error('Failed to analyze text: ${e.toString()}');
    }
  }

  Future<ApiResponse<EmotionData>> analyzeVoice(String audioData) async {
    final response = await _apiClient.post(
      '/emotion/voice',
      body: {'audio_data': audioData},
      fromJson: (json) => EmotionData.fromJson(json),
    );

    if (response.success) {
      return ApiResponse.success(response.data!);
    } else {
      return ApiResponse.error(response.message ?? 'Voice analysis failed');
    }
  }

  Future<ApiResponse<EmotionData>> analyzeImage(File imageFile) async {
    try {
      final multipartFile = await _apiClient.createMultipartFile(
        imageFile,
        fieldName: 'file',
      );

      final response = await _apiClient.multipartPost(
        '/predict/image',
        files: [multipartFile],
        fromJson: (json) => EmotionData.fromJson(json),
      );

      if (response.success) {
        return ApiResponse.success(response.data!);
      } else {
        return ApiResponse.error(response.message ?? 'Image analysis failed');
      }
    } catch (e) {
      return ApiResponse.error('Failed to analyze image: ${e.toString()}');
    }
  }

  Future<ApiResponse<EmotionData>> analyzeImageBytes(
    List<int> imageBytes, {
    String fileName = 'image.jpg',
    String mimeType = 'image/jpeg',
  }) async {
    try {
      final multipartFile = await _apiClient.createMultipartFileFromBytes(
        imageBytes,
        fileName: fileName,
        mimeType: mimeType,
        fieldName: 'file',
      );

      final response = await _apiClient.multipartPost(
        '/predict/image',
        files: [multipartFile],
        fromJson: (json) => EmotionData.fromJson(json),
      );

      if (response.success) {
        return ApiResponse.success(response.data!);
      } else {
        return ApiResponse.error(response.message ?? 'Image analysis failed');
      }
    } catch (e) {
      return ApiResponse.error('Failed to analyze image: ${e.toString()}');
    }
  }
}
