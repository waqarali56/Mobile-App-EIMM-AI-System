/// Model for GET /sessions/{session_id}/messages response item
class ChatMessageModel {
  final String role;       // "user" or "psychologist"
  final String content;
  final String? emotion;
  final DateTime timestamp;

  ChatMessageModel({
    required this.role,
    required this.content,
    this.emotion,
    required this.timestamp,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    final ts = json['timestamp'] as String?;
    return ChatMessageModel(
      role: json['role'] as String? ?? 'user',
      content: json['content'] as String? ?? '',
      emotion: json['emotion'] as String?,
      timestamp: ts != null ? DateTime.tryParse(ts) ?? DateTime.now() : DateTime.now(),
    );
  }

  bool get isUser => role == 'user';
}
