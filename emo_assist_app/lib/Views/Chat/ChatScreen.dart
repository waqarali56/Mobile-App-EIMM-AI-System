// Screens/Chat/ChatScreen.dart
import 'package:emo_assist_app/Services/navigation_service.dart';
import 'package:emo_assist_app/Views/CommonWidgets/AppBarWidget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emo_assist_app/Resources/Constants.dart';
import 'package:emo_assist_app/ViewModels/ChatViewModel.dart';
import 'package:emo_assist_app/Views/Chat/Widgets/ChatMessageBubble.dart';
import 'package:emo_assist_app/Views/Chat/Widgets/ChatInputArea.dart';
import 'package:emo_assist_app/Views/Chat/Widgets/EmptyChatState.dart';
import 'package:emo_assist_app/Views/Chat/Widgets/MultiModalOptionsPanel.dart';
import 'package:emo_assist_app/Views/CommonWidgets/DrawerWidget.dart';
import 'package:emo_assist_app/Views/Chat/Widgets/TypingIndicator.dart';

class ChatScreen extends StatelessWidget {
  ChatScreen({super.key});

  final ChatViewModel viewModel = Get.find<ChatViewModel>();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Constants.backgroundColor,
      appBar: AppBarWidget(scaffoldKey: _scaffoldKey), // ADD THIS LINE
      drawer: DrawerWidget(scaffoldKey: _scaffoldKey),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                // Multi-modal options panel
                MultiModalOptionsPanel(viewModel: viewModel),

                // Chat messages area - takes available space
                Expanded(child: _buildChatContent(constraints.maxHeight)),

                // Typing indicator
                TypingIndicator(viewModel: viewModel),

                // Input area - fixed at bottom
                ChatInputArea(
                  viewModel: viewModel,
                  scrollController: _scrollController,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Chat content (messages or empty state)
  Widget _buildChatContent(double maxHeight) {
    return Obx(() {
      if (viewModel.messages.isEmpty) {
        return EmptyChatState(maxHeight: maxHeight, viewModel: viewModel);
      }
      return _buildChatMessages();
    });
  }

  // Chat messages list
  Widget _buildChatMessages() {
    return Obx(() {
      // Scroll to bottom when new message arrives
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });

      return ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: viewModel.messages.length,
        itemBuilder: (context, index) {
          final message = viewModel.messages[index];
          final isUser = message.startsWith('You:');
          final messageText = isUser
              ? message.substring(4)
              : message.substring(10);

          return ChatMessageBubble(
            message: messageText,
            isUser: isUser,
            index: index,
            viewModel: viewModel,
          );
        },
      );
    });
  }
}
