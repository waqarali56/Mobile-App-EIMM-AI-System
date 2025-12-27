// lib/Views/Chat/Widgets/ChatInputArea.dart
import 'dart:io';
import 'package:emo_assist_app/ViewModels/Chat/ChatViewModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emo_assist_app/Resources/Constants.dart';

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
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main input area
        Container(
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
              // Image preview
              Obx(() {
                if (widget.viewModel.selectedImage.value != null) {
                  return _buildImagePreview();
                }
                return const SizedBox.shrink();
              }),

              // Replace the quick action buttons section:
// Multi-modal quick actions
              Obx(() {
                if (!widget.viewModel.isPremiumUser.value)
                  return const SizedBox.shrink();

                return Container(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Voice recording button
                      Obx(() {
                        final isRecording =
                            widget.viewModel.isRecordingAudio.value;
                        return _buildQuickActionButton(
                          icon: isRecording ? Icons.stop : Icons.mic,
                          label: isRecording
                              ? 'Stop (${widget.viewModel.recordingDuration.value}s)'
                              : 'Voice',
                          onPressed: () {
                            if (isRecording) {
                              widget.viewModel.stopAudioRecording();
                            } else {
                              widget.viewModel.startAudioRecording();
                            }
                          },
                        );
                      }),

                      // Video recording button
                      _buildQuickActionButton(
                        icon: Icons.videocam,
                        label: 'Video',
                        onPressed: () =>
                            widget.viewModel.recordVideoWithCamera(),
                      ),

                      // Mood/face button
                      _buildQuickActionButton(
                        icon: Icons.face,
                        label: 'Face',
                        onPressed: () => _startFaceAnalysis(),
                      ),
                    ],
                  ),
                );
              }),

              // Main input row
              Row(
                children: [
                  // Attachment button with image picker
                  PopupMenuButton<String>(
                    icon: Container(
                      decoration: BoxDecoration(
                        color: Constants.inputBackground,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add_circle_outline,
                        color: Constants.primaryColor,
                        size: 24,
                      ),
                    ),
                    padding: const EdgeInsets.all(8),
                    onSelected: (value) {
                      switch (value) {
                        case 'camera':
                          widget.viewModel.takePhoto();
                          break;
                        case 'gallery':
                          widget.viewModel.pickImageFromGallery();
                          break;
                        case 'files':
                          _showAttachmentOptions();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'camera',
                        child: Row(
                          children: [
                            Icon(Icons.camera_alt, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Camera'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'gallery',
                        child: Row(
                          children: [
                            Icon(Icons.photo_library, color: Colors.green),
                            SizedBox(width: 8),
                            Text('Gallery'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'files',
                        child: Row(
                          children: [
                            Icon(Icons.attach_file, color: Colors.orange),
                            SizedBox(width: 8),
                            Text('Other Files'),
                          ],
                        ),
                      ),
                    ],
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
                  Obx(() {
                    final hasText = _messageController.text.trim().isNotEmpty;
                    final hasImage =
                        widget.viewModel.selectedImage.value != null;

                    return Container(
                      decoration: BoxDecoration(
                        color: (hasText || hasImage)
                            ? Constants.primaryColor
                            : Colors.grey,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (hasText || hasImage)
                                ? Constants.primaryColor.withOpacity(0.3)
                                : Colors.grey.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          hasImage
                              ? Icons.send_and_archive
                              : Icons.send_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: (hasText || hasImage) ? _sendMessage : null,
                        padding: const EdgeInsets.all(12),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),

        // Upload notification overlay
        Positioned(
          top: -50, // Start above the input area
          left: 0,
          right: 0,
          child: Obx(() {
            if (widget.viewModel.showUploadNotification.value) {
              return _buildUploadNotification();
            }
            return const SizedBox.shrink();
          }),
        ),
      ],
    );
  }

  Widget _buildUploadNotification() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Constants.primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // Loading indicator
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              value: widget.viewModel.uploadProgress.value,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(Constants.primaryColor),
            ),
          ),

          const SizedBox(width: 12),

          // Status text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Processing Image',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Constants.textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.viewModel.uploadStatus.value,
                  style: TextStyle(
                    fontSize: 12,
                    color: Constants.textColor.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),

                // Progress bar
                LinearProgressIndicator(
                  value: widget.viewModel.uploadProgress.value,
                  backgroundColor: Colors.grey[200],
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Constants.primaryColor),
                  minHeight: 2,
                ),
              ],
            ),
          ),

          // Cancel button (optional)
          // IconButton(
          //   icon: Icon(Icons.close, size: 18, color: Colors.grey),
          //   onPressed: () {
          //     // Optional: Add cancel functionality
          //   },
          // ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Constants.inputBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Constants.inputBorder),
      ),
      child: Row(
        children: [
          // Image thumbnail
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Constants.dividerColor),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                widget.viewModel.selectedImage.value!,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Constants.inputBackground,
                    child: const Icon(Icons.image, color: Colors.grey),
                  );
                },
              ),
            ),
          ),

          const SizedBox(width: 12),

          // File info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Image Selected',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Constants.textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ready to analyze emotions',
                  style: TextStyle(
                    fontSize: 12,
                    color: Constants.textColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

          // Clear button
          IconButton(
            icon: Icon(
              Icons.close,
              color: Colors.red,
              size: 20,
            ),
            onPressed: () {
              widget.viewModel.clearSelectedImage();
            },
          ),
        ],
      ),
    );
  }

  // In ChatInputArea - Update _buildQuickActionButton
Widget _buildQuickActionButton({
  required IconData icon,
  required String label,
  required VoidCallback onPressed,
  Color? color,
}) {
  return GestureDetector(
    onTap: onPressed,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color ?? Constants.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Constants.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color ?? Constants.primaryColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color ?? Constants.textColor.withOpacity(0.8),
            ),
          ),
        ],
      ),
    ),
  );
}

  void _sendMessage() {
    final message = _messageController.text.trim();
    final hasImage = widget.viewModel.selectedImage.value != null;

    if (message.isNotEmpty) {
      widget.viewModel.sendMessage(message);
      _messageController.clear();
    }

    // Process image if selected
    if (hasImage) {
      widget.viewModel
          .processSelectedImage(widget.viewModel.selectedImage.value!);
    }

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

  // In _showAttachmentOptions method, update the options:
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
            Text(
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
                _buildAttachmentOption(Icons.photo, 'Photo', () {
                  Get.back();
                  widget.viewModel.pickImageFromGallery();
                }),
                _buildAttachmentOption(Icons.videocam, 'Record Video', () {
                  Get.back();
                  widget.viewModel.recordVideoWithCamera();
                }),
                _buildAttachmentOption(Icons.video_library, 'Video', () {
                  Get.back();
                  widget.viewModel.pickVideoFromGallery();
                }),
                _buildAttachmentOption(Icons.audio_file, 'Audio', () {
                  Get.back();
                  widget.viewModel.pickAudioFile();
                }),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Constants.inputBackground,
                foregroundColor: Constants.textColor,
              ),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption(
      IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Constants.inputBackground,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Constants.inputBorder),
            ),
            child: Icon(icon, size: 30, color: Constants.primaryColor),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Constants.textColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
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
      titleStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Constants.textColor,
      ),
      middleText:
          'Get access to multi-modal emotion detection:\n• Voice tone analysis\n• Facial expression recognition\n• Advanced emotional insights\n• Priority support',
      middleTextStyle: TextStyle(
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
