/// Response model for POST /analyze (multimodal: text, audio, image, video)
class MultimodalAnalyzeResponse {
  final FusionResult fusionResult;
  final AnalyzeBreakdown? breakdown;

  MultimodalAnalyzeResponse({
    required this.fusionResult,
    this.breakdown,
  });

  factory MultimodalAnalyzeResponse.fromJson(Map<String, dynamic> json) {
    return MultimodalAnalyzeResponse(
      fusionResult: FusionResult.fromJson(
        json['fusion_result'] as Map<String, dynamic>,
      ),
      breakdown: json['breakdown'] != null
          ? AnalyzeBreakdown.fromJson(
              json['breakdown'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class FusionResult {
  final String finalFusedEmotion;
  final String psychologistResponse;
  final double totalProcessingTimeSeconds;

  FusionResult({
    required this.finalFusedEmotion,
    required this.psychologistResponse,
    required this.totalProcessingTimeSeconds,
  });

  factory FusionResult.fromJson(Map<String, dynamic> json) {
    return FusionResult(
      finalFusedEmotion:
          json['final_fused_emotion'] as String? ?? 'unknown',
      psychologistResponse:
          json['psychologist_response'] as String? ?? '',
      totalProcessingTimeSeconds:
          (json['total_processing_time_seconds'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class AnalyzeBreakdown {
  final TextBreakdown? text;

  AnalyzeBreakdown({this.text});

  factory AnalyzeBreakdown.fromJson(Map<String, dynamic> json) {
    return AnalyzeBreakdown(
      text: json['text'] != null
          ? TextBreakdown.fromJson(json['text'] as Map<String, dynamic>)
          : null,
    );
  }
}

class TextBreakdown {
  final List<SentenceBreakdown> sentences;
  final String finalEmotion;
  final Map<String, double> weightedProbabilities;

  TextBreakdown({
    required this.sentences,
    required this.finalEmotion,
    required this.weightedProbabilities,
  });

  factory TextBreakdown.fromJson(Map<String, dynamic> json) {
    return TextBreakdown(
      sentences: (json['sentences'] as List<dynamic>?)
              ?.map((s) =>
                  SentenceBreakdown.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      finalEmotion: json['final_emotion'] as String? ?? 'unknown',
      weightedProbabilities:
          (json['weighted_probabilities'] as Map<String, dynamic>?)
                  ?.map((k, v) => MapEntry(k, (v as num).toDouble())) ??
              {},
    );
  }
}

class SentenceBreakdown {
  final String sentence;
  final String emotion;
  final Map<String, double> probabilities;

  SentenceBreakdown({
    required this.sentence,
    required this.emotion,
    required this.probabilities,
  });

  factory SentenceBreakdown.fromJson(Map<String, dynamic> json) {
    return SentenceBreakdown(
      sentence: json['sentence'] as String? ?? '',
      emotion: json['emotion'] as String? ?? 'unknown',
      probabilities:
          (json['probabilities'] as Map<String, dynamic>?)
                  ?.map((k, v) => MapEntry(k, (v as num).toDouble())) ??
              {},
    );
  }
}
