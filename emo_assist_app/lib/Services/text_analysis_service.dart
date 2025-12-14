// lib/Services/TextAnalysisService.dart
import '../Models/TextEmotionData.dart';
import '../Resources/api_client.dart';

class TextAnalysisService {
  final ApiClient _apiClient = ApiClient();

  Future<ApiResponse<TextEmotionData>> analyzeText(String paragraph) async {
    final response = await _apiClient.post(
      '/predict_text',
      body: {'paragraph': paragraph},
      fromJson: (json) => TextEmotionData.fromJson(json),
    );
    
    if (response.success) {
      return ApiResponse.success(response.data!);
    } else {
      return ApiResponse.error(response.message ?? 'Text analysis failed');
    }
  }
}