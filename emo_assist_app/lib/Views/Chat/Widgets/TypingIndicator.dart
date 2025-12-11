// Views/Chat/Widgets/TypingIndicator.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emo_assist_app/Resources/Constants.dart';
import 'package:emo_assist_app/ViewModels/ChatViewModel.dart';

class TypingIndicator extends StatelessWidget {
  final ChatViewModel viewModel;

  const TypingIndicator({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Check if viewModel.showTypingIndicator is reactive (RxBool)
      final bool isTyping;
      if (viewModel.showTypingIndicator is RxBool) {
        // It's an RxBool, use .value
        isTyping = (viewModel.showTypingIndicator as RxBool).value;
      } else if (viewModel.showTypingIndicator is bool) {
        // It's a regular bool
        isTyping = viewModel.showTypingIndicator as bool;
      } else {
        // Fallback
        isTyping = false;
      }
      
      if (!isTyping) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Container(
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
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Constants.chatAIBubble,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTypingDot(0),
                  _buildTypingDot(1),
                  _buildTypingDot(2),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTypingDot(int index) {
    return Container(
      width: 6,
      height: 6,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: Constants.textColor.withOpacity(0.6),
        shape: BoxShape.circle,
      ),
    );
  }
}