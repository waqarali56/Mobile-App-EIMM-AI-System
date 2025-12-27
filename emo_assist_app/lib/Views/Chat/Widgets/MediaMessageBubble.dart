// lib/Views/Chat/Widgets/MediaMessageBubble.dart
import 'package:emo_assist_app/Resources/Constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MediaMessageBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final String? mediaType; // 'image', 'voice', 'video'
  final String? fileName;
  final String? fileSize;

  const MediaMessageBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.mediaType,
    this.fileName,
    this.fileSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          // Media header
          if (mediaType != null && fileName != null)
            _buildMediaHeader(context),
          
          // Message content
          _buildMessageContent(context),
          
          // Timestamp
          _buildTimestamp(),
        ],
      ),
    );
  }

  Widget _buildMediaHeader(BuildContext context) {
    IconData icon;
    Color iconColor;
    String typeText;
    
    switch (mediaType) {
      case 'image':
        icon = Icons.image;
        iconColor = Colors.green;
        typeText = 'Image';
        break;
      case 'voice':
        icon = Icons.mic;
        iconColor = Colors.blue;
        typeText = 'Voice Message';
        break;
      case 'video':
        icon = Icons.videocam;
        iconColor = Colors.purple;
        typeText = 'Video';
        break;
      default:
        icon = Icons.attach_file;
        iconColor = Colors.grey;
        typeText = 'File';
    }
    
    return Container(
      margin: EdgeInsets.only(bottom: 8, left: isUser ? 0 : 40, right: isUser ? 40 : 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUser ? Constants.primaryColor.withOpacity(0.1) : Constants.chatAIBubble,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Constants.inputBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                typeText,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Constants.textColor,
                ),
              ),
              if (fileName != null)
                Text(
                  fileName!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Constants.textColor.withOpacity(0.7),
                  ),
                ),
              if (fileSize != null)
                Text(
                  fileSize!,
                  style: TextStyle(
                    fontSize: 11,
                    color: Constants.textColor.withOpacity(0.5),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    final bool hasAnalysis = message.contains('**Analysis Results**') ||
        message.contains('**Detected Emotion**') ||
        message.contains('**Face Detected**');
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        // Avatar for AI messages
        if (!isUser)
          Container(
            margin: const EdgeInsets.only(right: 8, top: 4),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Constants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.psychology,
              size: 18,
              color: Constants.primaryColor,
            ),
          ),
        
        // Message bubble
        Flexible(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.85,
            ),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isUser
                  ? Constants.primaryColor
                  : hasAnalysis
                      ? Colors.blue[50]?.withOpacity(0.9)
                      : Constants.chatAIBubble,
              borderRadius: BorderRadius.circular(20),
              border: hasAnalysis && !isUser
                  ? Border.all(color: Colors.blue[200]!)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: _buildMessageText(),
          ),
        ),
        
        // Avatar for user messages
        if (isUser)
          Container(
            margin: const EdgeInsets.only(left: 8, top: 4),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Constants.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.person,
              size: 18,
              color: Constants.primaryColor,
            ),
          ),
      ],
    );
  }

  Widget _buildMessageText() {
    final lines = message.split('\n');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        final isBold = line.contains('**') && line.indexOf('**') != line.lastIndexOf('**');
        final isHeader = line.contains('**Analysis Results**') || 
                        line.contains('**Detected Emotion**') ||
                        line.contains('**Face Detected**');
        final isListItem = line.trim().startsWith('•') || line.trim().startsWith('-');
        final isEmojiLine = _containsEmoji(line) && line.length < 20;
        
        String processedLine = line.replaceAll('**', '');
        
        return Padding(
          padding: EdgeInsets.only(bottom: isHeader ? 12 : 4),
          child: Text(
            processedLine,
            style: TextStyle(
              fontSize: isHeader ? 15 : 14,
              fontWeight: isBold || isHeader ? FontWeight.w600 : FontWeight.normal,
              color: isUser ? Colors.white : Constants.textColor,
              height: isListItem ? 1.5 : 1.3,
            ),
          ),
        );
      }).toList(),
    );
  }

  bool _containsEmoji(String text) {
    final emojiRegex = RegExp(
      r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])'
    );
    return emojiRegex.hasMatch(text);
  }

  Widget _buildTimestamp() {
    final now = DateTime.now();
    final time = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    return Container(
      margin: EdgeInsets.only(
        top: 4,
        left: isUser ? 0 : 50,
        right: isUser ? 50 : 0,
      ),
      child: Text(
        time,
        style: TextStyle(
          fontSize: 11,
          color: Constants.textColor.withOpacity(0.4),
        ),
      ),
    );
  }
}