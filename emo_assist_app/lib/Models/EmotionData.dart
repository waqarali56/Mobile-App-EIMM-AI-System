class EmotionData {
  final int facesDetected;
  final List<EmotionResult> results;

  EmotionData({
    required this.facesDetected,
    required this.results,
  });

  factory EmotionData.fromJson(Map<String, dynamic> json) {
    return EmotionData(
      facesDetected: json['faces_detected'] ?? 0,
      results: (json['results'] as List?)
              ?.map((item) => EmotionResult.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class EmotionResult {
  final String emotion;
  final double confidence;
  final Map<String, double> probabilities;

  EmotionResult({
    required this.emotion,
    required this.confidence,
    required this.probabilities,
  });

  factory EmotionResult.fromJson(Map<String, dynamic> json) {
    return EmotionResult(
      emotion: json['emotion'] ?? 'Unknown',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      probabilities: Map<String, double>.from(
          json['probabilities'] ?? {}),
    );
  }
}

enum EmotionSource {
  text,
  voice,
  facial,
  fused,
}



