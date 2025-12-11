// Screens/Drawer/ChatHistoryScreen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emo_assist_app/Resources/Constants.dart';
import 'package:emo_assist_app/Services/navigation_service.dart';

class ChatHistoryScreen extends StatelessWidget {
  const ChatHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date section
          _buildDateSection('Today'),
          _buildChatItem('Feeling anxious today', '10:30 AM'),
          _buildChatItem('Need motivation for work', '09:15 AM'),
          
          const SizedBox(height: 24),
          _buildDateSection('Yesterday'),
          _buildChatItem('Relationship advice', '08:45 PM'),
          _buildChatItem('Career guidance', '02:20 PM'),
          
          const SizedBox(height: 24),
          _buildDateSection('Last Week'),
          _buildChatItem('Stress management', 'Mon, 3:45 PM'),
          _buildChatItem('Sleep issues', 'Tue, 10:15 AM'),
          
          // Empty state
          const SizedBox(height: 32),
          _buildEmptyState(),
        ],
      ),
    );
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

  Widget _buildChatItem(String title, String time) {
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
              Get.snackbar(
                'Chat History',
                'Opening conversation: $title',
                snackPosition: SnackPosition.BOTTOM,
              );
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
            'No more chat history',
            style: TextStyle(
              fontSize: 16,
              color: Constants.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your recent conversations will appear here',
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