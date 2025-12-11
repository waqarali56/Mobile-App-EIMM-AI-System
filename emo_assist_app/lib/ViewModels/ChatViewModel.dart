// ViewModels/ChatViewModel.dart
import 'package:emo_assist_app/Services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:emo_assist_app/ViewModels/AuthViewModel.dart';

class ChatViewModel extends GetxController {
  // Core chat properties
  final RxList<String> messages = <String>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isGuestMode = false.obs;
  final RxBool isTyping = false.obs;

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

  // File attachments
  final RxList<String> selectedFiles = <String>[].obs;

  // Conversation management
  final RxString currentConversationId = ''.obs;
  final RxList<Map<String, dynamic>> conversations =
      <Map<String, dynamic>>[].obs;

  // Multi-modal options
  final RxBool showMultiModalOptions = false.obs;

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

    Get.snackbar('💬 New Chat', 'Started a new conversation');
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
    final userMessages = messages
        .where((msg) => msg.startsWith('You:'))
        .toList();
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

    // Clear current messages
    messages.clear();
    selectedFiles.clear();

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

    // Check premium status
    isPremiumUser.value = prefs.getBool('is_premium') ?? false;
    final userEmail = prefs.getString('user_email');

    // For demo purposes, simulate premium for specific emails
    if (userEmail != null &&
        (userEmail.endsWith('@premium.com') || userEmail.contains('premium'))) {
      isPremiumUser.value = true;
      await prefs.setBool('is_premium', true);
    }

    // Generate initial conversation ID
    if (currentConversationId.value.isEmpty) {
      currentConversationId.value = _generateConversationId();
    }

    isLoading.value = false;
  }

  void _addWelcomeMessage() {
    // Add initial welcome message
    messages.add(
      'EmoAssist: Hi there! 👋 I\'m EmoAssist, your emotional support companion. I\'m here to listen and help you understand your feelings better. How can I assist you today?',
    );
  }

  void sendMessage(String message) {
    if (message.trim().isEmpty) return;

    // Add user message
    messages.add('You: $message');

    // Update emotion scores based on message content
    _updateEmotionScores(message);

    // Show typing indicator
    isTyping.value = true;

    // Save conversation after user message
    _saveCurrentConversation();

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

  String _generateResponse(String userMessage) {
    final lowercaseMessage = userMessage.toLowerCase();

    if (lowercaseMessage.contains('how are you') ||
        lowercaseMessage.contains('how do you feel')) {
      return 'I\'m here and ready to help you understand your feelings. How are you feeling today?';
    } else if (lowercaseMessage.contains('sad') ||
        lowercaseMessage.contains('depressed') ||
        lowercaseMessage.contains('unhappy')) {
      currentEmotion.value = 'Sadness Detected';
      return 'I\'m sorry to hear you\'re feeling this way. It\'s okay to feel sad sometimes. Would you like to talk about what\'s bothering you?';
    } else if (lowercaseMessage.contains('happy') ||
        lowercaseMessage.contains('good') ||
        lowercaseMessage.contains('great')) {
      currentEmotion.value = 'Positive Mood';
      return 'That\'s wonderful to hear! 😊 I\'m glad you\'re feeling positive. Would you like to share what made you happy today?';
    } else if (lowercaseMessage.contains('anxious') ||
        lowercaseMessage.contains('worried') ||
        lowercaseMessage.contains('stressed')) {
      currentEmotion.value = 'Anxiety Detected';
      return 'Anxiety can be overwhelming. Remember to take deep breaths. Would you like some relaxation techniques?';
    } else if (lowercaseMessage.contains('thank') ||
        lowercaseMessage.contains('thanks')) {
      return 'You\'re welcome! I\'m always here for you. Is there anything else you\'d like to discuss?';
    } else if (lowercaseMessage.contains('help') ||
        lowercaseMessage.contains('support')) {
      return 'I\'m here to provide emotional support. You can share your feelings, thoughts, or anything that\'s on your mind.';
    } else if (lowercaseMessage.contains('love') ||
        lowercaseMessage.contains('relationship')) {
      currentEmotion.value = 'Relationship Focus';
      return 'Relationships can bring various emotions. Would you like to discuss your feelings about this relationship?';
    } else if (lowercaseMessage.contains('work') ||
        lowercaseMessage.contains('job') ||
        lowercaseMessage.contains('career')) {
      currentEmotion.value = 'Work Stress';
      return 'Work-related stress is common. Remember to take breaks and maintain work-life balance.';
    } else if (lowercaseMessage.contains('family') ||
        lowercaseMessage.contains('friend')) {
      return 'Relationships with family and friends are important. How do these relationships make you feel?';
    } else if (lowercaseMessage.contains('sleep') ||
        lowercaseMessage.contains('tired')) {
      currentEmotion.value = 'Fatigue Detected';
      return 'Sleep is crucial for emotional well-being. Are you having trouble sleeping?';
    } else if (lowercaseMessage.contains('premium') ||
        lowercaseMessage.contains('upgrade')) {
      return 'Premium features include voice and facial emotion analysis for deeper emotional insights. Would you like to learn more?';
    } else if (lowercaseMessage.contains('voice') ||
        lowercaseMessage.contains('speak')) {
      return isPremiumUser.value
          ? 'Voice analysis is enabled for you. Feel free to use the microphone button!'
          : 'Voice analysis is a premium feature. Upgrade to unlock multi-modal emotion detection.';
    } else if (lowercaseMessage.contains('face') ||
        lowercaseMessage.contains('camera')) {
      return isPremiumUser.value
          ? 'Facial expression analysis is active. The camera can help detect emotional cues.'
          : 'Facial analysis requires premium access for privacy-protected emotion detection.';
    } else if (lowercaseMessage.contains('new chat') ||
        lowercaseMessage.contains('start over')) {
      return 'You can start a new conversation anytime using the "New Chat" option in the menu. Would you like to continue here or start fresh?';
    } else if (lowercaseMessage.contains('conversation') ||
        lowercaseMessage.contains('history')) {
      return 'You can access all your previous conversations from the Chat History section. Each conversation is saved separately.';
    } else {
      // Default empathetic responses
      final responses = [
        'Thank you for sharing that with me. How does that make you feel?',
        'I understand. Can you tell me more about that?',
        'That sounds challenging. How have you been coping with it?',
        'I hear you. It\'s important to acknowledge these feelings.',
        'Thank you for trusting me with this. Would you like to explore this feeling further?',
        'I appreciate you opening up. What do you think would help you feel better?',
        'Your feelings are valid. Let\'s work through this together.',
        'It takes courage to share these thoughts. I\'m here to support you.',
      ];

      return responses[DateTime.now().millisecondsSinceEpoch %
          responses.length];
    }
  }

  void _updateEmotionScores(String message) {
    final lowercaseMessage = message.toLowerCase();

    // Update text sentiment based on keywords
    if (lowercaseMessage.contains('happy') ||
        lowercaseMessage.contains('good') ||
        lowercaseMessage.contains('great') ||
        lowercaseMessage.contains('love')) {
      textSentimentScore.value = 0.85 + (DateTime.now().millisecond % 15) / 100;
    } else if (lowercaseMessage.contains('sad') ||
        lowercaseMessage.contains('bad') ||
        lowercaseMessage.contains('angry') ||
        lowercaseMessage.contains('hate')) {
      textSentimentScore.value = 0.30 + (DateTime.now().millisecond % 20) / 100;
    } else if (lowercaseMessage.contains('anxious') ||
        lowercaseMessage.contains('worried') ||
        lowercaseMessage.contains('stressed')) {
      textSentimentScore.value = 0.45 + (DateTime.now().millisecond % 25) / 100;
    } else {
      textSentimentScore.value = 0.65 + (DateTime.now().millisecond % 20) / 100;
    }

    // Simulate voice tone changes (premium only)
    if (isPremiumUser.value) {
      voiceToneScore.value = 0.25 + (DateTime.now().second % 50) / 100;
    }

    // Simulate facial expression changes (premium only)
    if (isPremiumUser.value) {
      facialExpressionScore.value = 0.10 + (DateTime.now().second % 30) / 100;
    }

    // Update overall emotion
    _updateCurrentEmotion();
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
