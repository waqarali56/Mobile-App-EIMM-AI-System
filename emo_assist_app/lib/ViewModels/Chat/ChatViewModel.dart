// lib/ViewModels/Chat/ChatViewModel.dart
import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:emo_assist_app/Models/TextEmotionData.dart';
import 'package:emo_assist_app/Models/MultimodalAnalyzeResponse.dart';
import 'package:emo_assist_app/Services/AudioVideoService.dart';
import 'package:emo_assist_app/Services/multimodal_analyze_service.dart';
import 'package:emo_assist_app/Services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:emo_assist_app/ViewModels/Auth/AuthViewModel.dart';
import 'package:emo_assist_app/Services/ImageService.dart';
import 'package:emo_assist_app/Models/MediaEmotionData.dart';

class ChatViewModel extends GetxController {
  // Core chat properties
  final RxList<String> messages = <String>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isGuestMode = false.obs;
  final RxBool isTyping = false.obs;
  final RxBool isAnalyzingText = false.obs; // New property for text analysis

  // Multi-modal and premium properties
  final RxBool isPremiumUser = false.obs;
  final RxBool isConnected = true.obs;
  final RxString connectionType = 'WiFi'.obs;

  // Multi-modal emotion values (simulated for UI)
  final RxDouble textSentimentScore = 0.80.obs;
  final RxDouble voiceToneScore = 0.30.obs;
  final RxDouble facialExpressionScore = 0.05.obs;

  final RxString currentEmotion = 'Mild Anxiety'.obs;
  final RxString emotionTag = 'Empathetic Response'.obs;

  // Image handling properties
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxBool isUploadingImage = false.obs;
  final RxDouble uploadProgress = 0.0.obs;
  final RxList<File> selectedImages = <File>[].obs;

  // Audio/Video properties
  final AudioVideoService _audioVideoService = AudioVideoService();
  final Rx<File?> selectedVideo = Rx<File?>(null);
  final Rx<File?> selectedAudio = Rx<File?>(null);
  final RxBool isRecordingAudio = false.obs;
  final RxInt recordingDuration = 0.obs;

  // File attachments
  final RxList<String> selectedFiles = <String>[].obs;

  // Conversation management
  final RxString currentConversationId = ''.obs;
  final RxList<Map<String, dynamic>> conversations =
      <Map<String, dynamic>>[].obs;
  final RxBool showMultiModalOptions = false.obs;

  // Services (single API: POST /analyze only)
  final ImageService _imageService = ImageService();
  final MultimodalAnalyzeService _multimodalService = MultimodalAnalyzeService();

  // For showing/hiding upload notification
  final RxString uploadStatus = ''.obs;
  final RxBool showUploadNotification = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkUserStatus();
    _addWelcomeMessage();
    _simulateConnectionChanges();
    _loadChatHistory();
    _loadConversations();
  }

  void toggleMultiModalOptions(bool value) {
    showMultiModalOptions.value = value;
  }

  /// Send multimodal message: text + optional image, video, voice. Single API: POST /analyze.
  Future<void> sendMultimodalMessage(String text) async {
    final hasText = text.trim().isNotEmpty;
    final hasImage = selectedImage.value != null;
    final hasVideo = selectedVideo.value != null;
    final hasAudio = selectedAudio.value != null;

    if (!hasText && !hasImage && !hasVideo && !hasAudio) return;

    isAnalyzingText.value = true;
    isTyping.value = true;
    showUploadNotification.value = true;
    uploadStatus.value = 'Analyzing...';
    uploadProgress.value = 0.0;

    final parts = <String>[];
    if (hasText) parts.add(text.trim());
    if (hasImage) parts.add('📷');
    if (hasVideo) parts.add('🎬');
    if (hasAudio) parts.add('🎤');
    final userLine = 'You: ${parts.join(' ')}';
    messages.add(userLine);

    try {
      uploadProgress.value = 0.3;
      final result = await _multimodalService.analyze(
        text: text.trim(),
        audio: selectedAudio.value,
        image: selectedImage.value,
        video: selectedVideo.value,
      );

      uploadProgress.value = 1.0;

      if (result.success && result.data != null) {
        final data = result.data!;
        _updateEmotionScoresFromFusion(data.fusionResult);

        final emotion = data.fusionResult.finalFusedEmotion;
        final response = data.fusionResult.psychologistResponse;

        String details = '📊 **Emotion:** ${_capitalizeFirst(emotion)}';
        if (data.fusionResult.totalProcessingTimeSeconds > 0) {
          details += '\n⏱ ${data.fusionResult.totalProcessingTimeSeconds.toStringAsFixed(1)}s';
        }
        messages.add('System: $details');
        messages.add('EmoAssist: $response');

        _updateConversationPreview(userLine, response);
        _saveCurrentConversation();

        Get.snackbar(
          '✅ Analysis complete',
          'Emotion: ${_capitalizeFirst(emotion)}',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          snackPosition: SnackPosition.TOP,
        );
      } else {
        messages.add('EmoAssist: Sorry, I couldn\'t analyze that. ${result.message ?? 'Please try again.'}');
        _saveCurrentConversation();
        Get.snackbar(
          '❌ Analysis failed',
          result.message ?? 'Try again',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      messages.add('EmoAssist: Something went wrong. Please try again.');
      _saveCurrentConversation();
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isAnalyzingText.value = false;
      isTyping.value = false;
      showUploadNotification.value = false;
      uploadStatus.value = '';
      uploadProgress.value = 0.0;
      clearSelectedImage();
      clearSelectedVideo();
      clearSelectedAudio();
    }
  }

  void _updateEmotionScoresFromFusion(FusionResult fusion) {
    final emotion = fusion.finalFusedEmotion.toLowerCase();
    if (emotion == 'joy' || emotion == 'happy') {
      textSentimentScore.value = 0.85;
      currentEmotion.value = 'Positive Mood';
    } else if (emotion == 'sad') {
      textSentimentScore.value = 0.25;
      currentEmotion.value = 'Sadness Detected';
    } else if (emotion == 'anger') {
      textSentimentScore.value = 0.20;
      currentEmotion.value = 'Anger Detected';
    } else if (emotion == 'fear') {
      textSentimentScore.value = 0.35;
      currentEmotion.value = 'Anxiety Detected';
    } else if (emotion == 'surprise') {
      textSentimentScore.value = 0.70;
      currentEmotion.value = 'Surprise Detected';
    } else if (emotion == 'love') {
      textSentimentScore.value = 0.90;
      currentEmotion.value = 'Love Detected';
    } else {
      textSentimentScore.value = 0.60;
      currentEmotion.value = 'Neutral State';
    }
    emotionTag.value = 'AI-Powered Analysis';
  }

  /// Format image analysis for display
  String _formatImageAnalysis(ImageEmotionData emotionData) {
    String result = '📸 **Image Analysis Results**\n\n';

    if (emotionData.facesDetected == 0) {
      result += 'No faces detected in the image.\n';
      result +=
          'Please upload an image with a clear face for emotion analysis.';
    } else if (emotionData.facesDetected == 1) {
      final emotion = emotionData.results.first;
      result += '✅ **Face Detected**\n';
      result += '**Primary Emotion:** ${_capitalizeFirst(emotion.emotion)}\n';
      result +=
          '**Confidence:** ${(emotion.confidence * 100).toStringAsFixed(1)}%\n\n';

      if (emotion.probabilities.isNotEmpty) {
        result += '**Detailed Analysis:**\n';

        // Sort probabilities by value (highest first)
        final sortedEntries = emotion.probabilities.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        for (var entry in sortedEntries) {
          final percentage = (entry.value * 100).toStringAsFixed(1);
          result += '• ${_capitalizeFirst(entry.key)}: $percentage%\n';
        }
      }

      // Add emoji based on emotion
      result +=
          '\n${_getEmotionEmoji(emotion.emotion)} ${_getEmotionMessage(emotion.emotion)}';
    } else {
      result += '👥 **${emotionData.facesDetected} Faces Detected**\n\n';

      for (var i = 0; i < emotionData.results.length; i++) {
        final emotion = emotionData.results[i];
        result += '**Face ${i + 1}:**\n';
        result += '  Emotion: ${_capitalizeFirst(emotion.emotion)}\n';
        result +=
            '  Confidence: ${(emotion.confidence * 100).toStringAsFixed(1)}%\n';

        // Show top 2 emotions for each face
        if (emotion.probabilities.isNotEmpty) {
          final sortedEntries = emotion.probabilities.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value))
            ..take(2);

          if (sortedEntries.length > 1) {
            result += '  Top emotions: ';
            for (var j = 0; j < min(2, sortedEntries.length); j++) {
              final entry = sortedEntries[j];
              final percentage = (entry.value * 100).toStringAsFixed(1);
              result += '${_capitalizeFirst(entry.key)} ($percentage%)';
              if (j < min(2, sortedEntries.length) - 1) result += ', ';
            }
            result += '\n';
          }
        }
        result += '\n';
      }
    }

    return result;
  }

  /// Format voice analysis for display
  String _formatVoiceAnalysis(VoiceEmotionData voiceData) {
    String result = '🎤 **Voice Analysis Results**\n\n';

    if (voiceData.error != null) {
      result += '❌ **Error:** ${voiceData.error}\n';
      result += 'Please try recording again or upload a different audio file.';
    } else if (voiceData.emotion != null) {
      result += '✅ **Analysis Complete**\n';
      result +=
          '**Detected Emotion:** ${_capitalizeFirst(voiceData.emotion!)}\n\n';

      if (voiceData.probabilities != null &&
          voiceData.probabilities!.isNotEmpty) {
        result += '**Emotion Breakdown:**\n';

        // Sort probabilities by value
        final sortedEntries = voiceData.probabilities!.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        for (var entry in sortedEntries) {
          final percentage = (entry.value * 100).toStringAsFixed(1);
          result += '• ${_capitalizeFirst(entry.key)}: $percentage%\n';
        }
      }

      // Add vocal characteristic insights
      result += '\n🎵 **Vocal Characteristics:**\n';
      result += _getVoiceInsights(voiceData.emotion!);
    } else {
      result += 'No emotion detected in the audio.\n';
      result +=
          'Please try speaking more clearly or upload a different recording.';
    }

    return result;
  }

  /// Format video analysis for display
  String _formatVideoAnalysis(VideoEmotionData videoData) {
    String result = '🎬 **Video Analysis Results**\n\n';

    result += '✅ **Analysis Complete**\n';
    result +=
        '**Overall Emotion:** ${_capitalizeFirst(videoData.finalEmotion)}\n\n';

    if (videoData.finalProbabilities.isNotEmpty) {
      result += '**Emotion Timeline Analysis:**\n';

      // Sort probabilities by value
      final sortedEntries = videoData.finalProbabilities.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      for (var entry in sortedEntries) {
        final percentage = (entry.value * 100).toStringAsFixed(1);
        result += '• ${_capitalizeFirst(entry.key)}: $percentage%\n';
      }
    }

    // Add interpretation
    result += '\n📊 **Interpretation:**\n';
    result += _getVideoInsights(videoData.finalEmotion);

    return result;
  }

  /// Helper methods
  /// Capitalize helper (unchanged but ensure it handles API labels)
  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;

    // Handle API labels
    final lowerText = text.toLowerCase();
    if (lowerText == 'suprise') {
      return 'Surprise'; // Fix API typo
    }

    return text[0].toUpperCase() + text.substring(1);
  }

  /// Get emoji for emotion (updated for API labels)
  String _getEmotionEmoji(String emotion) {
    final lowerEmotion = emotion.toLowerCase();

    switch (lowerEmotion) {
      case 'joy':
        return '😊';
      case 'sad':
        return '😢';
      case 'anger':
        return '😠';
      case 'surprise':
        return '😲';
      case 'suprise':
        return '😲'; // Handle API typo
      case 'fear':
        return '😨';
      case 'love':
        return '❤️';
      case 'neutral':
        return '😐';
      default:
        return '🤔';
    }
  }

  String _getEmotionMessage(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy':
        return 'I see happiness in this image! Keep smiling!';
      case 'sad':
        return 'I detect sadness. It\'s okay to feel this way sometimes.';
      case 'angry':
        return 'I sense anger. Taking deep breaths can help.';
      case 'surprise':
        return 'Surprise detected! Something unexpected?';
      case 'fear':
        return 'I see fear. Remember, you\'re safe here.';
      case 'neutral':
        return 'Neutral expression detected. How are you really feeling?';
      default:
        return 'Emotion analysis complete.';
    }
  }

  String _getVoiceInsights(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy':
        return '• Bright, energetic tone\n• Higher pitch variations\n• Faster speech rate';
      case 'sad':
        return '• Slower speech rate\n• Lower pitch\n• Softer volume';
      case 'angry':
        return '• Louder volume\n• Sharper tone\n• Faster speech with pauses';
      case 'neutral':
        return '• Steady pace\n• Moderate pitch\n• Consistent volume';
      default:
        return '• Unique vocal patterns detected';
    }
  }

  String _getVideoInsights(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy':
        return 'The video shows predominantly happy expressions. Smiles and positive facial cues were detected throughout.';
      case 'sad':
        return 'The analysis indicates moments of sadness. Facial expressions show signs of emotional distress.';
      case 'angry':
        return 'Angry expressions were detected. There are visible signs of frustration or irritation.';
      case 'neutral':
        return 'Mostly neutral expressions detected. Emotional variance was minimal throughout the video.';
      default:
        return 'Mixed emotional expressions detected throughout the video timeline.';
    }
  }

  /// Format emotion details for display (updated for API labels)
  String _formatEmotionDetails(TextEmotionData emotionData) {
    String details = '📊 **Text Emotion Analysis Results**\n\n';
    details += '✅ **Analysis Complete**\n';
    details +=
        '**Overall Emotion:** ${_capitalizeFirst(emotionData.finalEmotion)}\n\n';

    // Show sentence-by-sentence analysis
    if (emotionData.sentences.isNotEmpty) {
      details += '**Sentence Analysis:**\n';
      for (var i = 0; i < emotionData.sentences.length; i++) {
        final sentence = emotionData.sentences[i];
        details += '${i + 1}. "${sentence.sentence}"\n';
        details += '   → Emotion: ${_capitalizeFirst(sentence.emotion)}\n';

        // Show top 2 probabilities for each sentence
        if (sentence.probabilities.isNotEmpty) {
          final sortedEntries = sentence.probabilities.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          details += '   → Top emotions: ';
          for (var j = 0; j < min(2, sortedEntries.length); j++) {
            final entry = sortedEntries[j];
            final percentage = (entry.value * 100).toStringAsFixed(1);
            details += '${_capitalizeFirst(entry.key)} ($percentage%)';
            if (j < min(2, sortedEntries.length) - 1) details += ', ';
          }
          details += '\n';
        }
        details += '\n';
      }
    }

    // Show weighted probabilities
    if (emotionData.weightedProbabilities.isNotEmpty) {
      details += '**Emotion Confidence Levels:**\n';

      // Sort by probability (highest first)
      final sortedEntries = emotionData.weightedProbabilities.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      for (var entry in sortedEntries) {
        final percentage = (entry.value * 100).toStringAsFixed(1);
        final emoji = _getEmotionEmoji(entry.key);
        details += '• $emoji ${_capitalizeFirst(entry.key)}: $percentage%\n';
      }
    }

    // Add interpretation based on emotion
    details += '\n**💡 Interpretation:**\n';
    details += _getTextEmotionInsights(emotionData.finalEmotion);

    return details.trim();
  }

  /// Helper method to get insights for text emotions
  String _getTextEmotionInsights(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'joy':
        return 'Your text shows clear signs of happiness and positivity. This is reflected in your choice of words and sentence structure.';
      case 'sad':
        return 'Your writing suggests feelings of sadness or melancholy. The emotional tone is subdued and reflective.';
      case 'anger':
        return 'There\'s evidence of frustration or anger in your text. The language shows intensity and strong emotion.';
      case 'fear':
        return 'Your message indicates some anxiety or worry. The uncertainty in your writing is noticeable.';
      case 'suprise':
      case 'surprise':
        return 'Your text has elements of surprise or unexpectedness. This creates an interesting emotional dynamic.';
      case 'love':
        return 'Your writing radiates warmth and affection. There\'s a positive, caring tone throughout.';
      default:
        return 'The emotional content of your text is complex and multifaceted.';
    }
  }

  /// Generate response based on detected emotion (updated for API labels)
  String _generateResponseFromEmotion(
      String message, TextEmotionData emotionData) {
    final emotion = emotionData.finalEmotion.toLowerCase();

    if (emotion == 'joy') {
      return 'I can sense the happiness in your message! 😊 That\'s wonderful to hear. What\'s bringing you joy today?';
    } else if (emotion == 'sad') {
      return 'I can tell you\'re feeling down right now. 😢 It\'s okay to feel this way. Would you like to talk about what\'s bothering you?';
    } else if (emotion == 'anger') {
      return 'I sense some frustration in your words. 😠 It\'s natural to feel angry sometimes. Take a deep breath. Would you like to talk about what\'s upsetting you?';
    } else if (emotion == 'fear') {
      return 'I can feel the worry in your message. 😨 Anxiety can be overwhelming. Remember, you\'re not alone. Let\'s work through this together.';
    } else if (emotion == 'suprise' || emotion == 'surprise') {
      return 'Something unexpected seems to have happened! 😲 Would you like to share more about it?';
    } else if (emotion == 'love') {
      return 'I can feel the warmth in your message! ❤️ That\'s beautiful. Would you like to share what you love about this?';
    } else if (emotion == 'context unclear') {
      return _generateResponse(message);
    } else {
      return 'Thank you for sharing that with me. I\'m here to listen and support you. How are you feeling right now?';
    }
  }

  /// Pick video from gallery (attachment only; sent with Send)
  Future<void> pickVideoFromGallery() async {
    try {
      final File? video = await _audioVideoService.pickVideoFromGallery(
        maxDuration: 120,
        maxFileSize: 100 * 1024 * 1024,
      );
      if (video != null) selectedVideo.value = video;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick video: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Record video with camera (attachment only; sent with Send)
  Future<void> recordVideoWithCamera() async {
    try {
      final File? video = await _audioVideoService.recordVideoWithCamera(
        maxDuration: 60,
      );
      if (video != null) selectedVideo.value = video;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to record video: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Start audio recording
  Future<void> startAudioRecording() async {
    try {
      final bool started = await _audioVideoService.startAudioRecording();
      isRecordingAudio.value = started;

      if (started) {
        // Start timer to update recording duration
        _startRecordingTimer();

        // Show recording UI
        Get.snackbar(
          '🎤 Recording Started',
          'Recording in WAV format... Speak clearly',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to start recording: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Stop audio recording (attachment only; sent with Send)
  Future<void> stopAudioRecording() async {
    try {
      final File? audio = await _audioVideoService.stopAudioRecording();
      isRecordingAudio.value = false;
      recordingDuration.value = 0;
      if (audio != null) selectedAudio.value = audio;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to stop recording: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Pick audio file (attachment only; sent with Send)
  Future<void> pickAudioFile() async {
    try {
      final File? audio = await _audioVideoService.pickAudioFile();
      if (audio != null) selectedAudio.value = audio;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick audio: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Add AI response for voice emotion (legacy; kept for history display)
  void _addVoiceEmotionResponse(VoiceEmotionData voiceData) {
    if (voiceData.error != null) {
      messages.add('EmoAssist: I couldn\'t analyze the audio properly. '
          'Please try recording again with clear speech and minimal background noise.');
      return;
    }

    if (voiceData.emotion == null) {
      messages
          .add('EmoAssist: I couldn\'t detect any clear emotion in the audio. '
              'Try speaking more clearly or with more emotional expression.');
      return;
    }

    final emotion = voiceData.emotion!.toLowerCase();
    String response = '';

    switch (emotion) {
      case 'happy':
        response = 'I can hear the happiness in your voice! 😊 '
            'Your tone sounds bright and energetic. Would you like to share what\'s making you happy?';
        break;
      case 'sad':
        response = 'I sense sadness in your voice. 😢 '
            'Your tone sounds softer and slower. It\'s okay to feel this way. '
            'Would talking about it help?';
        break;
      case 'angry':
        response = 'I can hear frustration or anger in your voice. 😠 '
            'The intensity in your tone suggests strong feelings. '
            'Take a deep breath - would you like to talk about what\'s bothering you?';
        break;
      case 'fear':
        response = 'I detect anxiety or fear in your voice. 😨 '
            'Your speech patterns suggest some nervousness. '
            'Remember, you\'re safe here. What\'s causing these feelings?';
        break;
      case 'surprise':
        response = 'Surprise detected in your voice! 😲 '
            'Your tone has that excited, surprised quality. '
            'Did something unexpected happen?';
        break;
      case 'neutral':
        response = 'Your voice sounds neutral. 😐 '
            'Sometimes our voices don\'t show what we\'re feeling inside. '
            'How are you really feeling right now?';
        break;
      default:
        response = 'Thank you for sharing your voice with me. '
            'Voice analysis is complete. How does hearing these results make you feel?';
    }

    messages.add('EmoAssist: $response');
  }

  /// Start recording timer
  void _startRecordingTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isRecordingAudio.value) {
        recordingDuration.value++;
      } else {
        timer.cancel();
      }
    });
  }

  /// Clear selected video
  void clearSelectedVideo() {
    selectedVideo.value = null;
  }

  /// Clear selected audio
  void clearSelectedAudio() {
    selectedAudio.value = null;
  }

  // Add message to chat - FIXED VERSION
  void addMessage(String message,
      {bool isUser = false, bool showTyping = true}) {
    if (isUser) {
      messages.add('You: $message');

      // Update emotion scores based on message content - FIXED
      _updateEmotionScoresFromMessage(message);

      // Only show typing indicator for text messages (not for images)
      if (showTyping) {
        isTyping.value = true;

        // Simulate AI response delay
        Future.delayed(const Duration(seconds: 1), () {
          isTyping.value = false;

          // Generate appropriate response based on message
          final response = _generateResponse(message);
          messages.add('EmoAssist: $response');

          // Update conversation preview
          _updateConversationPreview(message, response);

          // Update emotion tag for some messages
          if (messages.length % 3 == 0) {
            emotionTag.value = _getRandomEmotionTag();
          }

          // Save conversation after AI response
          _saveCurrentConversation();
        });
      }

      // Save conversation after user message
      _saveCurrentConversation();
    } else {
      messages.add('EmoAssist: $message');
    }
  }

  // Start a new conversation
  void startNewConversation() {
    // Save current conversation if it has messages
    if (messages.length > 1) {
      // More than just welcome message
      _saveCurrentConversation();
    }

    // Clear current conversation
    messages.clear();
    selectedFiles.clear();
    clearSelectedImage();

    // Generate new conversation ID
    currentConversationId.value = _generateConversationId();

    // Add welcome message
    _addWelcomeMessage();

    // Add to conversations list
    conversations.insert(0, {
      'id': currentConversationId.value,
      'title': _generateConversationTitle(),
      'timestamp': DateTime.now(),
      'preview': 'New conversation started',
      'messageCount': 1,
    });
  }

  // Generate conversation ID
  String _generateConversationId() {
    return 'conv_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Generate conversation title
  String _generateConversationTitle() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour < 12) {
      return 'Morning Chat';
    } else if (hour < 17) {
      return 'Afternoon Chat';
    } else {
      return 'Evening Chat';
    }
  }

  // Save current conversation
  Future<void> _saveCurrentConversation() async {
    if (messages.length <= 1) return; // Don't save if only welcome message

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedConversations =
          prefs.getStringList('saved_conversations') ?? [];

      final conversationData = {
        'id': currentConversationId.value.isNotEmpty
            ? currentConversationId.value
            : _generateConversationId(),
        'title': _getConversationTitleFromMessages(),
        'timestamp': DateTime.now().toIso8601String(),
        'messages': messages.toList(),
        'messageCount': messages.length,
      };

      // Convert to JSON string
      final conversationJson = conversationData.toString();
      savedConversations.add(conversationJson);

      // Keep only last 50 conversations
      if (savedConversations.length > 50) {
        savedConversations.removeAt(0);
      }

      await prefs.setStringList('saved_conversations', savedConversations);
    } catch (e) {
      print('Error saving conversation: $e');
    }
  }

  // Load conversations from storage
  Future<void> _loadConversations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedConversations =
          prefs.getStringList('saved_conversations') ?? [];

      conversations.clear();
      for (var convJson in savedConversations) {
        try {
          // Parse conversation data (simplified parsing)
          // In a real app, you'd use proper JSON parsing
          conversations.add({
            'id': 'conv_${savedConversations.indexOf(convJson)}',
            'title': 'Previous Conversation',
            'timestamp': DateTime.now().subtract(
              Duration(days: savedConversations.indexOf(convJson)),
            ),
            'preview': 'Previous chat',
            'messageCount': 5,
          });
        } catch (e) {
          continue;
        }
      }

      // Sort by timestamp (newest first)
      conversations.sort(
        (a, b) =>
            (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime),
      );
    } catch (e) {
      print('Error loading conversations: $e');
    }
  }

  String _getConversationTitleFromMessages() {
    if (messages.length <= 1) return 'Empty Chat';

    // Get first user message
    final userMessages =
        messages.where((msg) => msg.startsWith('You:')).toList();
    if (userMessages.isNotEmpty) {
      final firstUserMessage = userMessages.first.replaceFirst('You: ', '');
      if (firstUserMessage.length > 30) {
        return '${firstUserMessage.substring(0, 30)}...';
      }
      return firstUserMessage;
    }

    return 'Untitled Chat';
  }

  // Load a specific conversation
  void loadConversation(String conversationId) {
    // Save current conversation first
    _saveCurrentConversation();

    // Clear current messages and images
    messages.clear();
    selectedFiles.clear();
    clearSelectedImage();

    // In a real app, you would load from storage
    // For now, simulate loading with sample messages
    messages.add(
      'EmoAssist: 👋 Welcome back! This is your previous conversation.',
    );
    messages.add('You: Hello, I was feeling anxious yesterday.');
    messages.add('EmoAssist: I remember that. How are you feeling today?');

    currentConversationId.value = conversationId;

    Get.snackbar(
      '📖 Conversation Loaded',
      'Switched to previous conversation',
      backgroundColor: Get.theme.primaryColor,
      colorText: Colors.white,
    );
  }

  // Delete a conversation
  Future<void> deleteConversation(String conversationId) async {
    conversations.removeWhere((conv) => conv['id'] == conversationId);

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedConversations =
          prefs.getStringList('saved_conversations') ?? [];

      // Remove the conversation (simplified)
      if (savedConversations.isNotEmpty) {
        savedConversations.removeAt(0); // In real app, find by ID
        await prefs.setStringList('saved_conversations', savedConversations);
      }
    } catch (e) {
      print('Error deleting conversation: $e');
    }

    Get.snackbar(
      '🗑️ Conversation Deleted',
      'The conversation has been removed',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  Future<void> _checkUserStatus() async {
    isLoading.value = true;
    final prefs = await SharedPreferences.getInstance();
    isGuestMode.value = prefs.getBool('is_guest') ?? false;
    isPremiumUser.value = prefs.getBool('is_premium') ?? false;

    if (currentConversationId.value.isEmpty) {
      currentConversationId.value = _generateConversationId();
    }

    isLoading.value = false;
  }

  void _addWelcomeMessage() {
    messages.add(
      'EmoAssist: Hi there! 👋 I\'m EmoAssist, your emotional support companion powered by AI emotion detection. How can I assist you today?',
    );
  }

  void _updateConversationPreview(String userMessage, String aiResponse) {
    if (conversations.isNotEmpty) {
      final index = conversations.indexWhere(
        (conv) => conv['id'] == currentConversationId.value,
      );
      if (index != -1) {
        conversations[index]['preview'] = aiResponse.length > 30
            ? '${aiResponse.substring(0, 30)}...'
            : aiResponse;
        conversations[index]['timestamp'] = DateTime.now();
        conversations[index]['messageCount'] = messages.length;
      }
    }
  }

  /// Original generate response method (fallback)
  String _generateResponse(String userMessage) {
    final lowercaseMessage = userMessage.toLowerCase();

    if (lowercaseMessage.contains('how are you')) {
      return 'I\'m here and ready to help you understand your feelings. How are you feeling today?';
    } else if (lowercaseMessage.contains('sad') ||
        lowercaseMessage.contains('depressed')) {
      return 'I\'m sorry to hear you\'re feeling this way. It\'s okay to feel sad sometimes. Would you like to talk about what\'s bothering you?';
    } else if (lowercaseMessage.contains('happy') ||
        lowercaseMessage.contains('good')) {
      return 'That\'s wonderful to hear! 😊 I\'m glad you\'re feeling positive. Would you like to share what made you happy today?';
    } else if (lowercaseMessage.contains('anxious') ||
        lowercaseMessage.contains('worried')) {
      return 'Anxiety can be overwhelming. Remember to take deep breaths. Would you like some relaxation techniques?';
    } else {
      final responses = [
        'Thank you for sharing that with me. How does that make you feel?',
        'I understand. Can you tell me more about that?',
        'That sounds challenging. How have you been coping with it?',
        'I hear you. It\'s important to acknowledge these feelings.',
      ];
      return responses[DateTime.now().millisecond % responses.length];
    }
  }

  /// Update emotion scores based on API response - SINGLE VERSION
  void _updateEmotionScoresFromAPI(TextEmotionData emotionData) {
    // Map API emotion labels to your UI labels
    final emotion = emotionData.finalEmotion.toLowerCase();

    if (emotion == 'joy') {
      textSentimentScore.value = 0.85 + (DateTime.now().millisecond % 10) / 100;
      currentEmotion.value = 'Positive Mood';
    } else if (emotion == 'sad') {
      textSentimentScore.value = 0.25 + (DateTime.now().millisecond % 15) / 100;
      currentEmotion.value = 'Sadness Detected';
    } else if (emotion == 'anger') {
      textSentimentScore.value = 0.20 + (DateTime.now().millisecond % 15) / 100;
      currentEmotion.value = 'Anger Detected';
    } else if (emotion == 'fear') {
      textSentimentScore.value = 0.35 + (DateTime.now().millisecond % 20) / 100;
      currentEmotion.value = 'Anxiety Detected';
    } else if (emotion == 'suprise' || emotion == 'surprise') {
      textSentimentScore.value = 0.70 + (DateTime.now().millisecond % 15) / 100;
      currentEmotion.value = 'Surprise Detected';
    } else if (emotion == 'love') {
      textSentimentScore.value = 0.90 + (DateTime.now().millisecond % 10) / 100;
      currentEmotion.value = 'Love Detected';
    } else {
      textSentimentScore.value = 0.60 + (DateTime.now().millisecond % 20) / 100;
      currentEmotion.value = 'Neutral State';
    }

    // Update emotion tag
    emotionTag.value = 'AI-Powered Analysis';
  }

  /// Update emotion scores based on simple message content analysis
  void _updateEmotionScoresFromMessage(String message) {
    final lowercaseMessage = message.toLowerCase();

    // Simple sentiment analysis for non-API fallback
    if (lowercaseMessage.contains('happy') ||
        lowercaseMessage.contains('good') ||
        lowercaseMessage.contains('great') ||
        lowercaseMessage.contains('excellent') ||
        lowercaseMessage.contains('awesome')) {
      textSentimentScore.value = 0.80 + (DateTime.now().millisecond % 15) / 100;
      currentEmotion.value = 'Positive Mood';
    } else if (lowercaseMessage.contains('sad') ||
        lowercaseMessage.contains('bad') ||
        lowercaseMessage.contains('terrible') ||
        lowercaseMessage.contains('awful')) {
      textSentimentScore.value = 0.25 + (DateTime.now().millisecond % 15) / 100;
      currentEmotion.value = 'Sadness Detected';
    } else if (lowercaseMessage.contains('angry') ||
        lowercaseMessage.contains('mad') ||
        lowercaseMessage.contains('frustrated')) {
      textSentimentScore.value = 0.20 + (DateTime.now().millisecond % 15) / 100;
      currentEmotion.value = 'Anger Detected';
    } else if (lowercaseMessage.contains('anxious') ||
        lowercaseMessage.contains('worried') ||
        lowercaseMessage.contains('scared')) {
      textSentimentScore.value = 0.35 + (DateTime.now().millisecond % 20) / 100;
      currentEmotion.value = 'Anxiety Detected';
    } else {
      textSentimentScore.value = 0.60 + (DateTime.now().millisecond % 20) / 100;
      currentEmotion.value = 'Neutral State';
    }

    // Update emotion tag
    emotionTag.value = 'Simple Analysis';
  }

  void _updateCurrentEmotion() {
    final double overallScore = textSentimentScore.value;

    if (overallScore > 0.75) {
      currentEmotion.value = 'Positive Mood';
    } else if (overallScore > 0.5) {
      currentEmotion.value = 'Neutral State';
    } else if (overallScore > 0.25) {
      currentEmotion.value = 'Mild Anxiety';
    } else {
      currentEmotion.value = 'Sadness Detected';
    }
  }

  String _getRandomEmotionTag() {
    final tags = [
      'Empathetic Response',
      'Supportive Message',
      'Active Listening',
      'Emotional Validation',
      'Therapeutic Response',
      'Mindful Approach',
      'Compassionate Reply',
    ];
    return tags[DateTime.now().millisecond % tags.length];
  }

  void _simulateConnectionChanges() {
    // Simulate network changes every 30 seconds
    Future.delayed(const Duration(seconds: 30), () {
      isConnected.value = DateTime.now().second % 10 != 0;
      connectionType.value = isConnected.value
          ? (DateTime.now().second % 2 == 0 ? 'WiFi' : '5G')
          : 'Offline';

      // Continue simulation
      _simulateConnectionChanges();
    });
  }

  // Premium upgrade method
  Future<void> upgradeToPremium() async {
    isLoading.value = true;

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_premium', true);
    isPremiumUser.value = true;

    isLoading.value = false;

    Get.snackbar(
      '🎉 Premium Activated',
      'You now have access to multi-modal emotion detection!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.primaryColor,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );

    // Update emotion scores for premium features
    voiceToneScore.value = 0.50;
    facialExpressionScore.value = 0.25;
  }

  // Getters for UI
  bool get showTypingIndicator => isTyping.value;

  String get textSentimentPercentage =>
      '${(textSentimentScore.value * 100).toInt()}%';
  String get voiceTonePercentage => isPremiumUser.value
      ? '${(voiceToneScore.value * 100).toInt()}%'
      : 'Locked';
  String get facialExpressionPercentage => isPremiumUser.value
      ? '${(facialExpressionScore.value * 100).toInt()}%'
      : 'Locked';

  Future<void> logout() async {
    // Save current conversation before logging out
    _saveCurrentConversation();

    final prefs = await SharedPreferences.getInstance();

    if (isGuestMode.value) {
      await prefs.remove('is_guest');
      await prefs.remove('chat_history');
      NavigationService.goToLogin();
    } else {
      final authViewModel = Get.find<AuthViewModel>();
      await authViewModel.logout();
    }
  }

  void clearChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('chat_history');
    await prefs.remove('saved_conversations');
    messages.clear();
    conversations.clear();
    clearSelectedImage();
    _addWelcomeMessage();
    currentConversationId.value = _generateConversationId();

    Get.snackbar(
      '🗑️ All Conversations Cleared',
      'Your chat history has been cleared.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }

  // Save chat history
  Future<void> saveChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('chat_history', messages);
      _saveCurrentConversation();
    } catch (e) {
      // Ignore error
    }
  }

  // Load chat history
  Future<void> _loadChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedHistory = prefs.getStringList('chat_history');
      if (savedHistory != null && savedHistory.isNotEmpty) {
        messages.assignAll(savedHistory);
      }
    } catch (e) {
      // Ignore error, start fresh
    }
  }

  // Image Picker Methods
  Future<void> pickImageFromGallery() async {
    try {
      final File? image = await _imageService.pickImageFromGallery(
        maxWidth: 1920,
        maxHeight: 1920,
        quality: 85,
      );

      if (image != null) {
        selectedImage.value = image;
        // Don't process automatically - wait for user to send
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> takePhoto() async {
    try {
      final File? image = await _imageService.takePhotoWithCamera(
        maxWidth: 1920,
        maxHeight: 1920,
        quality: 85,
      );

      if (image != null) {
        selectedImage.value = image;
        // Don't process automatically - wait for user to send
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to take photo: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> pickMultipleImages() async {
    try {
      final List<File> images = await _imageService.pickMultipleImages(
        maxImages: 5,
        maxWidth: 1920,
        maxHeight: 1920,
        quality: 85,
      );

      if (images.isNotEmpty) {
        selectedImages.value = images;
        // Process first image automatically
        if (images.isNotEmpty) {
          selectedImage.value = images.first;
          // Don't process automatically - wait for user to send
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick images: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Image is sent only via Send button with other attachments (single /analyze API).
  Future<void> processSelectedImage(File image) async {
    // No-op; use Send button to analyze (calls POST /analyze with all attachments).
  }

  /// Add AI response based on detected emotion
  void _addEmotionBasedResponse(ImageEmotionData emotionData) {
    if (emotionData.facesDetected == 0) {
      messages.add('EmoAssist: I couldn\'t detect any faces in the image. '
          'For accurate emotion analysis, please upload a clear photo with a visible face.');
      return;
    }

    final primaryEmotion = emotionData.results.first.emotion.toLowerCase();
    String response = '';

    switch (primaryEmotion) {
      case 'happy':
        response = 'I can see the happiness in this image! 😊 '
            'That bright smile says a lot. Would you like to share what made you so happy today?';
        break;
      case 'sad':
        response = 'I sense some sadness here. 😢 '
            'It\'s completely okay to feel this way. Remember, every cloud has a silver lining. '
            'Would talking about it help?';
        break;
      case 'angry':
        response = 'I can see signs of frustration or anger. 😠 '
            'Sometimes expressing these feelings can help release them. '
            'Take a deep breath - would you like to talk about what\'s bothering you?';
        break;
      case 'fear':
        response = 'I detect some anxiety or fear in this expression. 😨 '
            'These feelings can be overwhelming, but you\'re not alone. '
            'What\'s causing these feelings? I\'m here to listen.';
        break;
      case 'surprise':
        response = 'Surprise! 😲 Did something unexpected happen? '
            'I\'d love to hear about it if you want to share.';
        break;
      case 'neutral':
        response = 'I see a neutral expression. 😐 '
            'Sometimes our faces don\'t show what we\'re feeling inside. '
            'How are you really feeling right now?';
        break;
      default:
        response = 'Thank you for sharing this image with me. '
            'Emotion analysis is complete. How does seeing these results make you feel?';
    }

    messages.add('EmoAssist: $response');
  }

  void clearSelectedImage() {
    selectedImage.value = null;
    selectedImages.clear();
  }

  @override
  void onClose() {
    // Save chat history when leaving
    if (!isGuestMode.value) {
      saveChatHistory();
      _saveCurrentConversation();
    }
    super.onClose();
  }
}
