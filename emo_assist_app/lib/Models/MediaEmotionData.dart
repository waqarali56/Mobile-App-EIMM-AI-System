class ImageEmotionData {
  final int facesDetected;
  final List<EmotionResult> results;

  ImageEmotionData({
    required this.facesDetected,
    required this.results,
  });

  factory ImageEmotionData.fromJson(Map<String, dynamic> json) {
    print('📋 [ImageEmotionData] Parsing JSON: $json');
    
    // Handle different response formats
    if (json.containsKey('emotion')) {
      // Single face response format: {"emotion":"sad","confidence":0.481,...}
      print('📋 [ImageEmotionData] Detected single face response format');
      final emotionResult = EmotionResult(
        emotion: json['emotion'] ?? 'Unknown',
        confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
        probabilities: (json['probabilities'] as Map<String, dynamic>?)
                ?.map((key, value) => MapEntry(key, (value as num).toDouble())) ??
            {},
      );
      
      return ImageEmotionData(
        facesDetected: 1,
        results: [emotionResult],
      );
    } else if (json.containsKey('faces_detected')) {
      // Multi-face response format
      print('📋 [ImageEmotionData] Detected multi-face response format');
      return ImageEmotionData(
        facesDetected: json['faces_detected'] ?? 0,
        results: (json['results'] as List?)
                ?.map((item) => EmotionResult.fromJson(item))
                .toList() ??
            [],
      );
    } else {
      // Fallback format
      print('📋 [ImageEmotionData] Using fallback parsing');
      return ImageEmotionData(
        facesDetected: 1,
        results: [
          EmotionResult(
            emotion: 'Unknown',
            confidence: 0.0,
            probabilities: {},
          )
        ],
      );
    }
  }
}



class VideoEmotionData {
  final String finalEmotion;
  final Map<String, double> finalProbabilities;

  VideoEmotionData({
    required this.finalEmotion,
    required this.finalProbabilities,
  });

  factory VideoEmotionData.fromJson(Map<String, dynamic> json) {
    return VideoEmotionData(
      finalEmotion: json['final_emotion'] ?? 'Unknown',
      finalProbabilities: Map<String, double>.from(
        json['final_probabilities'] ?? {},
      ),
    );
  }
}

class VoiceEmotionData {
  final String? error;
  final String? emotion;
  final Map<String, double>? probabilities;

  VoiceEmotionData({
    this.error,
    this.emotion,
    this.probabilities,
  });

  factory VoiceEmotionData.fromJson(Map<String, dynamic> json) {
    return VoiceEmotionData(
      error: json['error'],
      emotion: json['emotion'],
      probabilities: json['probabilities'] != null
          ? Map<String, double>.from(json['probabilities'])
          : null,
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
        json['probabilities'] ?? {},
      ),
    );
  }
}