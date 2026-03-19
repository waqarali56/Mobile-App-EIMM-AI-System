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
              // Mini attachment indicators (text, img, video, voice)
              Obx(() => _buildAttachmentChips()),

              // Image preview when single image selected
              Obx(() {
                if (widget.viewModel.selectedImage.value != null) {
                  return _buildImagePreview();
                }
                return const SizedBox.shrink();
              }),

              // Multi-modal quick actions (text, video, voice, img — all use single Send)
              Container(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
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
                    _buildQuickActionButton(
                      icon: Icons.videocam,
                      label: 'Video',
                      onPressed: () =>
                          widget.viewModel.recordVideoWithCamera(),
                    ),
                    _buildQuickActionButton(
                      icon: Icons.face,
                      label: 'Face',
                      onPressed: () => _startFaceAnalysis(),
                    ),
                  ],
                ),
              ),

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
                              onChanged: (_) => setState(() {}),
                              onSubmitted: (_) => _sendMessage(),
                              style: TextStyle(
                                fontSize: 14,
                                color: Constants.textColor,
                              ),
                            ),
                          ),

                          // Voice hint (mic in quick actions above)
                          const SizedBox.shrink(),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Send button (enabled when text, img, video, or voice attached)
                  Obx(() {
                    final hasText = _messageController.text.trim().isNotEmpty;
                    final hasImage =
                        widget.viewModel.selectedImage.value != null;
                    final hasVideo =
                        widget.viewModel.selectedVideo.value != null;
                    final hasAudio =
                        widget.viewModel.selectedAudio.value != null;
                    final canSend =
                        hasText || hasImage || hasVideo || hasAudio;

                    return Container(
                      decoration: BoxDecoration(
                        color: canSend
                            ? Constants.primaryColor
                            : Colors.grey,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: canSend
                                ? Constants.primaryColor.withOpacity(0.3)
                                : Colors.grey.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: canSend ? _sendMessage : null,
                        padding: const EdgeInsets.all(12),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),

        // Upload notification overlay - FIXED POSITION
        Obx(() {
          if (widget.viewModel.showUploadNotification.value) {
            return Positioned(
              // Position above the input area, accounting for keyboard
              bottom: MediaQuery.of(context).viewInsets.bottom + 57,
              left: 0,
              right: 0,
              child: _buildUploadNotification(),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildAttachmentChips() {
    final hasText = _messageController.text.trim().isNotEmpty;
    final hasImg = widget.viewModel.selectedImage.value != null;
    final hasVideo = widget.viewModel.selectedVideo.value != null;
    final hasVoice = widget.viewModel.selectedAudio.value != null;
    if (!hasText && !hasImg && !hasVideo && !hasVoice) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.only(bottom: 6),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: [
          if (hasText)
            _buildChip(Icons.text_fields, 'text', null),
          if (hasImg)
            _buildChip(Icons.image, 'img', () => widget.viewModel.clearSelectedImage()),
          if (hasVideo)
            _buildChip(Icons.videocam, 'video', () => widget.viewModel.clearSelectedVideo()),
          if (hasVoice)
            _buildChip(Icons.mic, 'voice', () => widget.viewModel.clearSelectedAudio()),
        ],
      ),
    );
  }

  Widget _buildChip(IconData icon, String label, VoidCallback? onClear) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Constants.primaryColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Constants.primaryColor.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Constants.primaryColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Constants.textColor.withOpacity(0.9),
            ),
          ),
          if (onClear != null) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onClear,
              child: Icon(Icons.close, size: 14, color: Constants.textColor.withOpacity(0.7)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUploadNotification() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 8), // Reduced vertical padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8), // Slightly smaller radius
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Lighter shadow
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Constants.primaryColor.withOpacity(0.2), // Lighter border
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Remove icon to save space
          // SizedBox(
          //   width: 24,
          //   height: 24,
          //   child: CircularProgressIndicator(
          //     strokeWidth: 2,
          //     value: widget.viewModel.uploadProgress.value,
          //     backgroundColor: Colors.grey[200],
          //     valueColor: AlwaysStoppedAnimation<Color>(Constants.primaryColor),
          //   ),
          // ),
          // const SizedBox(width: 8),

          // Status text with thin progress bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Thin progress bar at the top (3px height)
                ClipRRect(
                  borderRadius: BorderRadius.circular(1.5),
                  child: LinearProgressIndicator(
                    value: widget.viewModel.uploadProgress.value,
                    backgroundColor: Colors.grey[200],
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Constants.primaryColor),
                    minHeight: 3, // Thin 3px bar
                  ),
                ),
                const SizedBox(height: 6), // Reduced spacing

                // Status text and percentage in same row
                Row(
                  children: [
                    // Status text
                    Expanded(
                      child: Text(
                        widget.viewModel.uploadStatus.value,
                        style: TextStyle(
                          fontSize: 12, // Smaller font
                          color: Constants.textColor.withOpacity(0.7),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),

                    // Percentage
                    Text(
                      '${(widget.viewModel.uploadProgress.value * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 11, // Smaller font
                        fontWeight: FontWeight.w600,
                        color: Constants.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to determine icon based on upload type
  IconData _getUploadIcon() {
    final status = widget.viewModel.uploadStatus.value.toLowerCase();
    if (status.contains('video')) return Icons.videocam;
    if (status.contains('voice') || status.contains('audio')) return Icons.mic;
    if (status.contains('image') || status.contains('photo'))
      return Icons.image;
    return Icons.cloud_upload;
  }

  // Helper method to determine title based on upload type
  String _getUploadTitle() {
    final status = widget.viewModel.uploadStatus.value.toLowerCase();
    if (status.contains('video')) return 'Processing Video';
    if (status.contains('voice') || status.contains('audio'))
      return 'Processing Voice';
    if (status.contains('image') || status.contains('photo'))
      return 'Processing Image';
    if (status.contains('emotion')) return 'Analyzing Emotions';
    return 'Uploading File';
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
            icon: const Icon(
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
    final hasVideo = widget.viewModel.selectedVideo.value != null;
    final hasAudio = widget.viewModel.selectedAudio.value != null;
    final canSend = message.isNotEmpty || hasImage || hasVideo || hasAudio;

    if (!canSend) return;

    widget.viewModel.sendMultimodalMessage(message);
    _messageController.clear();

    FocusScope.of(context).unfocus();

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
      'Feature coming soon!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Constants.primaryColor,
      colorText: Colors.white,
    );
  }

  void _startFaceAnalysis() {
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
              'Add image for emotion analysis',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Constants.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap Send after selecting to analyze',
              style: TextStyle(
                fontSize: 13,
                color: Constants.textColor.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  Icons.camera_alt,
                  'Camera',
                  () {
                    Get.back();
                    widget.viewModel.takePhoto();
                  },
                ),
                _buildAttachmentOption(
                  Icons.photo_library,
                  'Gallery',
                  () {
                    Get.back();
                    widget.viewModel.pickImageFromGallery();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
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
      'Feature Notice',
      'Voice input feature is coming soon!',
      snackPosition: SnackPosition.BOTTOM,
      mainButton: TextButton(
        onPressed: _showPremiumUpgrade,
        child: const Text('OK', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _showPremiumUpgrade() {
    Get.defaultDialog(
      title: 'Feature Access',
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
      textConfirm: 'Continue',
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
