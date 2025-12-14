// Views/Chat/Widgets/ChatMessageBubble.dart
import 'package:emo_assist_app/ViewModels/Chat/ChatViewModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emo_assist_app/Resources/Constants.dart';

class ChatMessageBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final int index;
  final ChatViewModel viewModel;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isUser,
    required this.index,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final time = _getSimulatedTime(index);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          // Sender label for bot messages
          if (!isUser)
            Padding(
              padding: const EdgeInsets.only(bottom: 4, left: 8),
              child: Row(
                children: [
                  // Bot avatar
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Constants.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.psychology,
                      size: 12,
                      color: Constants.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'MindSpace',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Constants.textColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 10,
                      color: Constants.textColor.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),

          // Message bubble
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              // Bot avatar for left side
              if (!isUser)
                Container(
                  margin: const EdgeInsets.only(right: 8),
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

              // Message content
              Flexible(
                child: Builder(
                  builder: (context) {
                    return Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isUser
                            ? Constants.primaryColor
                            : Constants.chatAIBubble,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message,
                            style: TextStyle(
                              fontSize: 14,
                              color: isUser
                                  ? Colors.white
                                  : Constants.textColor,
                            ),
                          ),
                          // Emotion tag for AI messages
                          if (!isUser && index % 3 == 0)
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Constants.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.tag,
                                    size: 10,
                                    color: Constants.primaryColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Obx(() {
                                    return Text(
                                      viewModel.emotionTag.value,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Constants.primaryColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // User time and avatar
              if (isUser)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 10,
                          color: Constants.textColor.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
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
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Simulated time for messages
  String _getSimulatedTime(int index) {
    final now = DateTime.now();
    final time = now.subtract(Duration(minutes: index * 2));
    final hour = time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '${hour == 0 ? 12 : hour}:$minute $period';
  }
}