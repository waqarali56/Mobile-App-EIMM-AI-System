class EmotionData {
  final String dominantEmotion;
  final Map<String, double> emotionScores;
  final DateTime timestamp;
  final EmotionSource source;

  EmotionData({
    required this.dominantEmotion,
    required this.emotionScores,
    required this.timestamp,
    required this.source,
  });

  factory EmotionData.fromJson(Map<String, dynamic> json) {
    return EmotionData(
      dominantEmotion: json['dominantEmotion'] ?? 'neutral',
      emotionScores: Map<String, double>.from(json['emotionScores'] ?? {}),
      timestamp: DateTime.parse(json['timestamp']),
      source: _parseEmotionSource(json['source']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dominantEmotion': dominantEmotion,
      'emotionScores': emotionScores,
      'timestamp': timestamp.toIso8601String(),
      'source': source.name,
    };
  }

  static EmotionSource _parseEmotionSource(String source) {
    switch (source) {
      case 'voice':
        return EmotionSource.voice;
      case 'facial':
        return EmotionSource.facial;
      case 'fused':
        return EmotionSource.fused;
      default:
        return EmotionSource.text;
    }
  }
}

enum EmotionSource {
  text,
  voice,
  facial,
  fused,
}