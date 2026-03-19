/// Model for GET /sessions response item
class ChatSessionModel {
  final String sessionId;
  final String title;
  final DateTime createdAt;

  ChatSessionModel({
    required this.sessionId,
    required this.title,
    required this.createdAt,
  });

  factory ChatSessionModel.fromJson(Map<String, dynamic> json) {
    final createdStr = json['created_at'] as String?;
    return ChatSessionModel(
      sessionId: json['session_id'] as String? ?? '',
      title: json['title'] as String? ?? 'Chat',
      createdAt: createdStr != null ? DateTime.tryParse(createdStr) ?? DateTime.now() : DateTime.now(),
    );
  }
}
