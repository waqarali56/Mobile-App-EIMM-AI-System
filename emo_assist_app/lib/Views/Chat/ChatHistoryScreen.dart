// Screens/Drawer/ChatHistoryScreen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emo_assist_app/Models/ChatSessionModel.dart';
import 'package:emo_assist_app/Resources/Constants.dart';
import 'package:emo_assist_app/Resources/RouteNames.dart';
import 'package:emo_assist_app/Services/navigation_service.dart';
import 'package:emo_assist_app/ViewModels/Chat/ChatHistoryViewModel.dart';

class ChatHistoryScreen extends StatelessWidget {
  const ChatHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Get.find<ChatHistoryViewModel>();
    return Scaffold(
      backgroundColor: Constants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Constants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        title: const Text(
          'Chat History',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => NavigationService.goBack(),
        ),
      ),
      body: Obx(() => _buildBody(viewModel)),
    );
  }

  Widget _buildBody(ChatHistoryViewModel viewModel) {
    if (viewModel.isLoading.value && viewModel.sessions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (viewModel.errorMessage.value.isNotEmpty && viewModel.sessions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                viewModel.errorMessage.value,
                textAlign: TextAlign.center,
                style: TextStyle(color: Constants.textColor),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => viewModel.loadSessions(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => viewModel.loadSessions(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildSections(viewModel),
        ),
      ),
    );
  }

  List<Widget> _buildSections(ChatHistoryViewModel viewModel) {
    final list = <Widget>[];
    String? lastSection;
    for (final session in viewModel.sessions) {
      final section = viewModel.sectionLabelFor(session.createdAt);
      if (section != lastSection) {
        if (lastSection != null) list.add(const SizedBox(height: 24));
        list.add(_buildDateSection(section));
        lastSection = section;
      }
      list.add(_buildChatItem(viewModel, session));
    }
    if (viewModel.sessions.isEmpty) {
      list.add(const SizedBox(height: 32));
      list.add(_buildEmptyState());
    }
    return list;
  }

  Widget _buildDateSection(String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        date,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Constants.textColor.withOpacity(0.7),
        ),
      ),
    );
  }

  Widget _buildChatItem(ChatHistoryViewModel viewModel, ChatSessionModel session) {
    final title = session.title;
    final time = viewModel.formatSessionTime(session.createdAt);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Constants.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Constants.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Constants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.psychology,
              color: Constants.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Constants.textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Constants.textColor.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.arrow_forward_ios,
              color: Constants.textColor.withOpacity(0.4),
              size: 16,
            ),
            onPressed: () {
              Get.toNamed(RouteNames.chat, arguments: {'sessionId': session.sessionId});
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Constants.textColor.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'No chat history yet',
            style: TextStyle(
              fontSize: 16,
              color: Constants.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your conversations will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Constants.textColor.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
