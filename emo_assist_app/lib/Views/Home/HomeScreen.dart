// Screens/Home/HomeScreen.dart
import 'package:emo_assist_app/Views/CommonWidgets/DrawerWidget.dart';
import 'package:emo_assist_app/Views/CommonWidgets/AppBarWidget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emo_assist_app/Resources/Constants.dart';
import 'package:emo_assist_app/Services/navigation_service.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Constants.backgroundColor,
      appBar: AppBarWidget(scaffoldKey: _scaffoldKey), // Custom AppBar
      drawer: DrawerWidget(scaffoldKey: _scaffoldKey),
      body: SafeArea(
        child: Column(
          children: [
            // Welcome Section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildWelcomeSection(),
                    const SizedBox(height: 30),
                    _buildQuickActions(),
                    const SizedBox(height: 30),
                    _buildFeaturesSection(),
                    const SizedBox(height: 30),
                    _buildRecentChats(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Constants.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Constants.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Constants.primaryColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.psychology, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 20),
          const Text(
            'Welcome to MindSpace',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Constants.textColor,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Your emotional support companion. Start a conversation, track your emotions, or explore features.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Constants.textColor),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => NavigationService.goToChat(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Constants.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Start Chatting',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Constants.textColor,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.chat,
                title: 'New Chat',
                description: 'Start conversation',
                onTap: () => NavigationService.goToChat(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.history,
                title: 'History',
                description: 'View past chats',
                onTap: () => NavigationService.goToChatHistory(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.emoji_emotions,
                title: 'Mood Check',
                description: 'Record your mood',
                onTap: () {
                  Get.snackbar(
                    'Mood Check',
                    'Feature coming soon!',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.insights,
                title: 'Insights',
                description: 'View analytics',
                onTap: () {
                  Get.snackbar(
                    'Insights',
                    'Feature coming soon!',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Constants.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Constants.dividerColor),
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
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Constants.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Constants.primaryColor, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Constants.textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: Constants.textColor.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Features',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Constants.textColor,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _buildFeatureCard(
              icon: Icons.text_fields,
              title: 'Text Analysis',
              subtitle: 'Sentiment detection',
            ),
            _buildFeatureCard(
              icon: Icons.mic,
              title: 'Voice Tone',
              subtitle: 'Premium feature',
              isPremium: true,
            ),
            _buildFeatureCard(
              icon: Icons.face,
              title: 'Facial Emotion',
              subtitle: 'Premium feature',
              isPremium: true,
            ),
            _buildFeatureCard(
              icon: Icons.psychology,
              title: 'AI Insights',
              subtitle: 'Emotional patterns',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isPremium = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Constants.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPremium
              ? Colors.amber.withOpacity(0.3)
              : Constants.dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isPremium
                      ? Colors.amber.withOpacity(0.1)
                      : Constants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isPremium ? Colors.amber : Constants.primaryColor,
                  size: 20,
                ),
              ),
              if (isPremium)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'PREMIUM',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Constants.textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Constants.textColor.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentChats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Conversations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Constants.textColor,
              ),
            ),
            TextButton(
              onPressed: () => NavigationService.goToChatHistory(),
              child: const Text(
                'View All',
                style: TextStyle(fontSize: 14, color: Constants.primaryColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildRecentChatItem(
          title: 'Feeling anxious today',
          time: 'Today, 10:30 AM',
          emotion: 'Anxious',
        ),
        _buildRecentChatItem(
          title: 'Need motivation for work',
          time: 'Today, 09:15 AM',
          emotion: 'Motivated',
        ),
        _buildRecentChatItem(
          title: 'Relationship advice',
          time: 'Yesterday, 08:45 PM',
          emotion: 'Reflective',
        ),
      ],
    );
  }

  Widget _buildRecentChatItem({
    required String title,
    required String time,
    required String emotion,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                Row(
                  children: [
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        color: Constants.textColor.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Constants.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        emotion,
                        style: TextStyle(
                          fontSize: 10,
                          color: Constants.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
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
            onPressed: () => NavigationService.goToChat(),
          ),
        ],
      ),
    );
  }
}
