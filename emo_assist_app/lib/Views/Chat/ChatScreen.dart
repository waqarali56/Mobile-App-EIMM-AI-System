import 'package:emo_assist_app/Resources/Constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emo_assist_app/ViewModels/ChatViewModel.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ChatViewModel viewModel = Get.find<ChatViewModel>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('EmoAssist Chat'),
        backgroundColor: Constants.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              // If there's a previous screen, go back
              Get.back();
            } else {
              // If no previous screen, go to login
              Get.offAllNamed('/login');
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => viewModel.logout(),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: const Center(
        child: Text('Chat Screen - Coming Soon'),
      ),
    );
  }
}