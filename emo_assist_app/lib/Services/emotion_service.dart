import '../Models/EmotionData.dart';
import '../Resources/api_client.dart';

class EmotionService {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResponse<EmotionData>> analyzeText(String text) async {
    final response = await _apiClient.post(
      '/emotion/text',
      body: {'text': text},
      fromJson: (json) => EmotionData.fromJson(json),
    );
    
    if (response.success) {
      return ApiResponse.success(response.data!);
    } else {
      return ApiResponse.error(response.message ?? 'Text analysis failed');
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

  Future<ApiResponse<EmotionData>> fuseEmotions(Map<String, dynamic> emotions) async {
    final response = await _apiClient.post(
      '/emotion/fuse',
      body: emotions,
      fromJson: (json) => EmotionData.fromJson(json),
    );
    
    if (response.success) {
      return ApiResponse.success(response.data!);
    } else {
      return ApiResponse.error(response.message ?? 'Emotion fusion failed');
    }
  }
}