/// Model for text emotion analysis response
class TextEmotionData {
  final List<SentenceEmotion> sentences;
  final String finalEmotion;
  final Map<String, double> weightedProbabilities;

  TextEmotionData({
    required this.sentences,
    required this.finalEmotion,
    required this.weightedProbabilities,
  });

  factory TextEmotionData.fromJson(Map<String, dynamic> json) {
    return TextEmotionData(
      sentences: (json['sentences'] as List<dynamic>?)
              ?.map((s) => SentenceEmotion.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      finalEmotion: json['final_emotion'] as String? ?? 'unknown',
      weightedProbabilities: (json['weighted_probabilities'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(key, (value as num).toDouble())) ??
          {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sentences': sentences.map((s) => s.toJson()).toList(),
      'final_emotion': finalEmotion,
      'weighted_probabilities': weightedProbabilities,
    };
  }
}

/// Model for individual sentence emotion
class SentenceEmotion {
  final String sentence;
  final String emotion;
  final Map<String, double> probabilities;

  SentenceEmotion({
    required this.sentence,
    required this.emotion,
    required this.probabilities,
  });

  factory SentenceEmotion.fromJson(Map<String, dynamic> json) {
    return SentenceEmotion(
      sentence: json['sentence'] as String? ?? '',
      emotion: json['emotion'] as String? ?? 'unknown',
      probabilities: (json['probabilities'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(key, (value as num).toDouble())) ??
          {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sentence': sentence,
      'emotion': emotion,
      'probabilities': probabilities,
    };
  }
}