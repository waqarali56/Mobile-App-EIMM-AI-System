// Screens/Chat/ChatScreen.dart
import 'package:emo_assist_app/Services/navigation_service.dart';
import 'package:emo_assist_app/ViewModels/Chat/ChatViewModel.dart';
import 'package:emo_assist_app/Views/Chat/Widgets/MediaMessageBubble.dart';
import 'package:emo_assist_app/Views/CommonWidgets/AppBarWidget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emo_assist_app/Resources/Constants.dart';
import 'package:emo_assist_app/Views/Chat/Widgets/ChatMessageBubble.dart';
import 'package:emo_assist_app/Views/Chat/Widgets/ChatInputArea.dart';
import 'package:emo_assist_app/Views/Chat/Widgets/EmptyChatState.dart';
import 'package:emo_assist_app/Views/Chat/Widgets/MultiModalOptionsPanel.dart';
import 'package:emo_assist_app/Views/CommonWidgets/DrawerWidget.dart';
import 'package:emo_assist_app/Views/Chat/Widgets/TypingIndicator.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatViewModel viewModel;
  late final ScrollController _scrollController;
  late final GlobalKey<ScaffoldState> _scaffoldKey;

  @override
  void initState() {
    super.initState();
    viewModel = Get.find<ChatViewModel>();
    _scrollController = ScrollController();
    _scaffoldKey = GlobalKey<ScaffoldState>();
    final args = Get.arguments;
    if (args is Map && args['sessionId'] != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        viewModel.loadSessionAndOpen(args['sessionId'] as String);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Constants.backgroundColor,
      appBar: AppBarWidget(scaffoldKey: _scaffoldKey),
      drawer: DrawerWidget(scaffoldKey: _scaffoldKey),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                MultiModalOptionsPanel(viewModel: viewModel),
                Expanded(child: _buildChatContent(constraints.maxHeight)),
                TypingIndicator(viewModel: viewModel),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  child: ChatInputArea(
                    viewModel: viewModel,
                    scrollController: _scrollController,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildChatContent(double maxHeight) {
    return Obx(() {
      if (viewModel.messages.isEmpty && !viewModel.isLoading.value) {
        return EmptyChatState(maxHeight: maxHeight, viewModel: viewModel);
      }
      if (viewModel.isLoading.value && viewModel.messages.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      return _buildChatMessages();
    });
  }

  Widget _buildChatMessages() {
    return Obx(() {
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
        final messageText = isUser ? message.substring(4) : message.substring(10);
        
        // Check if this is a media message
        final isMediaMessage = message.contains('📷') || 
                               message.contains('🎤') || 
                               message.contains('🎬');
        
        if (isMediaMessage) {
          // Extract media info
          String? mediaType;
          String? fileName;
          String? fileSize;
          
          if (message.contains('📷')) mediaType = 'image';
          if (message.contains('🎤')) mediaType = 'voice';
          if (message.contains('🎬')) mediaType = 'video';
          
          // Extract filename and size (simplified parsing)
          final fileMatch = RegExp(r'"(.*?)" \((.*?)\)').firstMatch(message);
          if (fileMatch != null) {
            fileName = fileMatch.group(1);
            fileSize = fileMatch.group(2);
          }
          
          return MediaMessageBubble(
            message: messageText,
            isUser: isUser,
            mediaType: mediaType,
            fileName: fileName,
            fileSize: fileSize,
          );
        } else {
          // Regular message bubble
          return ChatMessageBubble(
            message: messageText,
            isUser: isUser,
            index: index,
            viewModel: viewModel,
          );
        }
      },
    );
  });
  }
}
