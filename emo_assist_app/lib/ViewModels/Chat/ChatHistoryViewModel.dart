// lib/ViewModels/Chat/ChatHistoryViewModel.dart
import 'package:emo_assist_app/Models/ChatSessionModel.dart';
import 'package:emo_assist_app/Services/sessions_service.dart';
import 'package:get/get.dart';

/// Manages state for Chat History: sessions list from GET /sessions.
class ChatHistoryViewModel extends GetxController {
  final SessionsService _sessionsService = SessionsService();

  final RxList<ChatSessionModel> sessions = <ChatSessionModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadSessions();
  }

  /// Fetch user sessions from API (GET /sessions).
  Future<void> loadSessions() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await _sessionsService.getSessions();
      if (response.success && response.data != null) {
        sessions.assignAll(response.data!);
      } else {
        errorMessage.value = response.message ?? 'Failed to load sessions';
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Format session time for display.
  String formatSessionTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessionDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    if (sessionDate == today) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.hour >= 12 ? 'PM' : 'AM'}';
    }
    final yesterday = today.subtract(const Duration(days: 1));
    if (sessionDate == yesterday) {
      return 'Yesterday, ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
    if (now.difference(dateTime).inDays < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return '${days[dateTime.weekday - 1]}, ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  /// Section label for grouping (Today, Yesterday, Last Week, or date).
  String sectionLabelFor(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessionDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    if (sessionDate == today) return 'Today';
    final yesterday = today.subtract(const Duration(days: 1));
    if (sessionDate == yesterday) return 'Yesterday';
    if (now.difference(dateTime).inDays < 7) return 'Last Week';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
