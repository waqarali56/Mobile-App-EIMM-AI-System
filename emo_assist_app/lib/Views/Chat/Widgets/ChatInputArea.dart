// Views/Chat/Widgets/ChatInputArea.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emo_assist_app/Resources/Constants.dart';
import 'package:emo_assist_app/ViewModels/ChatViewModel.dart';

class ChatInputArea extends StatefulWidget {
  final ChatViewModel viewModel;
  final ScrollController scrollController;

  const ChatInputArea({
    super.key,
    required this.viewModel,
    required this.scrollController,
  });

  @override
  State<ChatInputArea> createState() => _ChatInputAreaState();
}

class _ChatInputAreaState extends State<ChatInputArea> {
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Constants.cardColor,
        border: Border(
          top: BorderSide(color: Constants.dividerColor, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Multi-modal quick actions
          Obx(() {
            if (!widget.viewModel.isPremiumUser.value)
              return const SizedBox.shrink();

            return Container(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildQuickActionButton(
                    icon: Icons.mic,
                    label: 'Voice',
                    onPressed: () => _startVoiceRecording(),
                  ),
                  _buildQuickActionButton(
                    icon: Icons.face,
                    label: 'Face',
                    onPressed: () => _startFaceAnalysis(),
                  ),
                  _buildQuickActionButton(
                    icon: Icons.mood,
                    label: 'Mood',
                    onPressed: () => _recordMood(),
                  ),
                ],
              ),
            );
          }),

          // Main input row
          Row(
            children: [
              // Attachment button
              Container(
                decoration: BoxDecoration(
                  color: Constants.inputBackground,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.add_circle_outline,
                    color: Constants.primaryColor,
                    size: 24,
                  ),
                  onPressed: _showAttachmentOptions,
                  padding: const EdgeInsets.all(8),
                ),
              ),
              const SizedBox(width: 8),

              // Text input field
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 100),
                  decoration: BoxDecoration(
                    color: Constants.inputBackground,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Constants.inputBorder),
                  ),
                  child: Row(
                    children: [
                      // Emoji button
                      IconButton(
                        icon: Icon(
                          Icons.emoji_emotions_outlined,
                          color: Constants.textColor.withOpacity(0.6),
                          size: 22,
                        ),
                        onPressed: () => _showEmojiPicker(),
                        padding: const EdgeInsets.all(8),
                      ),

                      // Text field
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Type your message...',
                            hintStyle: TextStyle(
                              color: Constants.textHintColor,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 12,
                            ),
                          ),
                          maxLines: 4,
                          minLines: 1,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendMessage(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Constants.textColor,
                          ),
                        ),
                      ),

                      // Voice input button (for free users)
                      Obx(() {
                        if (widget.viewModel.isPremiumUser.value)
                          return const SizedBox.shrink();

                        return IconButton(
                          icon: Icon(
                            Icons.mic_none,
                            color: Constants.textColor.withOpacity(0.6),
                            size: 22,
                          ),
                          onPressed: _showPremiumPrompt,
                          padding: const EdgeInsets.all(8),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Send button
              Container(
                decoration: BoxDecoration(
                  color: Constants.primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Constants.primaryColor.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: _sendMessage,
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Constants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Constants.primaryColor.withOpacity(0.3),
              ),
            ),
            child: Icon(icon, size: 20, color: Constants.primaryColor),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Constants.textColor.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      widget.viewModel.sendMessage(message);
      _messageController.clear();
      FocusScope.of(context).unfocus();

      // Scroll to bottom after sending
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.scrollController.hasClients) {
          widget.scrollController.animateTo(
            widget.scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _startVoiceRecording() {
    Get.snackbar(
      'Voice Recording',
      'Premium feature - Coming soon!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Constants.primaryColor,
      colorText: Colors.white,
    );
  }

  void _startFaceAnalysis() {
    Get.snackbar(
      'Facial Analysis',
      'Premium feature - Coming soon!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Constants.primaryColor,
      colorText: Colors.white,
    );
  }

  void _recordMood() {
    Get.snackbar(
      'Mood Recording',
      'Feature coming soon!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showEmojiPicker() {
    Get.snackbar(
      'Emoji Picker',
      'Feature coming soon!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showAttachmentOptions() {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Constants.cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Attach File',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Constants.textColor,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(Icons.photo, 'Photo'),
                _buildAttachmentOption(Icons.video_library, 'Video'),
                _buildAttachmentOption(Icons.audio_file, 'Audio'),
                _buildAttachmentOption(Icons.insert_drive_file, 'Document'),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption(IconData icon, String label) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, size: 30),
          onPressed: () {
            Get.back();
            Get.snackbar(
              'Coming Soon',
              '$label attachment feature coming soon!',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Constants.textColor.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  void _showPremiumPrompt() {
    Get.snackbar(
      'Premium Feature',
      'Upgrade to premium for voice input!',
      snackPosition: SnackPosition.BOTTOM,
      mainButton: TextButton(
        onPressed: _showPremiumUpgrade,
        child: const Text('UPGRADE', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _showPremiumUpgrade() {
    Get.defaultDialog(
      title: 'Upgrade to Premium',
      titleStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Constants.textColor,
      ),
      middleText:
          'Get access to multi-modal emotion detection:\n• Voice tone analysis\n• Facial expression recognition\n• Advanced emotional insights\n• Priority support',
      middleTextStyle: const TextStyle(
        fontSize: 14,
        color: Constants.textColor,
      ),
      textConfirm: 'Upgrade Now',
      textCancel: 'Maybe Later',
      confirmTextColor: Colors.white,
      cancelTextColor: Constants.textColor,
      buttonColor: Constants.primaryColor,
      onConfirm: () {
        Get.back();
        widget.viewModel.upgradeToPremium();
      },
    );
  }
}
