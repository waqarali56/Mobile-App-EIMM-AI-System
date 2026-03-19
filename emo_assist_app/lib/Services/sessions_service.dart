// lib/Services/sessions_service.dart
import 'package:emo_assist_app/Models/ChatSessionModel.dart';
import 'package:emo_assist_app/Models/ChatMessageModel.dart';
import 'package:emo_assist_app/Resources/api_client.dart';
import 'package:emo_assist_app/ViewModels/Auth/AuthViewModel.dart';
import 'package:get/get.dart';

/// Service for GET /sessions and GET /sessions/{session_id}/messages (orchestrator API).
class SessionsService {
  final ApiClient _apiClient = ApiClient();

  /// GET /sessions - returns list of chat sessions for the logged-in user.
  Future<ApiResponse<List<ChatSessionModel>>> getSessions() async {
    final response = await _apiClient.get<List<ChatSessionModel>>(
      '/sessions',
      fromJson: (dynamic json) {
        if (json is! List) return <ChatSessionModel>[];
        return (json as List)
            .map((e) => ChatSessionModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
    if (response.success && response.data != null) {
      return ApiResponse.success(response.data!);
    }
    return ApiResponse.error(response.message ?? 'Failed to load sessions');
  }

  /// GET /sessions/{session_id}/messages - returns chat history for a session.
  Future<ApiResponse<List<ChatMessageModel>>> getSessionMessages(String sessionId) async {
    if (sessionId.trim().isEmpty) {
      return ApiResponse.error('Session ID is required');
    }
    if (Get.isRegistered<AuthViewModel>()) {
      await Get.find<AuthViewModel>().ensureFreshAccessTokenForProtectedApis();
    }
    final response = await _apiClient.get<List<ChatMessageModel>>(
      '/sessions/$sessionId/messages',
      fromJson: (dynamic json) {
        if (json is! List) return <ChatMessageModel>[];
        return (json as List)
            .map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
    if (response.success && response.data != null) {
      return ApiResponse.success(response.data!);
    }
    return ApiResponse.error(response.message ?? 'Failed to load messages');
  }
}
