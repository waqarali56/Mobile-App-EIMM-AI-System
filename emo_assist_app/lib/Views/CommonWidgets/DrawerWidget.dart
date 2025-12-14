// Views/Chat/Widgets/DrawerWidget.dart
import 'package:emo_assist_app/ViewModels/Chat/ChatViewModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emo_assist_app/Resources/Constants.dart';
import 'package:emo_assist_app/Services/navigation_service.dart';

class DrawerWidget extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const DrawerWidget({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    final ChatViewModel viewModel = Get.find<ChatViewModel>();

    return Drawer(
      backgroundColor: Constants.cardColor,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header
            _buildDrawerHeader(viewModel),

            // Drawer Options
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 16),
                children: [
                  // New Chat Button - Added at the top
                  _buildDrawerItem(
                    icon: Icons.add_comment,
                    title: 'New Chat',
                    onTap: () {
                      scaffoldKey.currentState?.closeDrawer();
                      viewModel.startNewConversation();
                      NavigationService.goToChat();
                    },
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(color: Constants.dividerColor, height: 16),
                  ),

                  _buildDrawerItem(
                    icon: Icons.home,
                    title: 'Home',
                    onTap: () {
                      scaffoldKey.currentState?.closeDrawer();
                      NavigationService.goToHome();
                    },
                  ),

                  _buildDrawerItem(
                    icon: Icons.history,
                    title: 'Chat History',
                    onTap: () {
                      scaffoldKey.currentState?.closeDrawer();
                      NavigationService.goToChatHistory();
                    },
                  ),

                  _buildDrawerItem(
                    icon: Icons.settings,
                    title: 'Settings',
                    onTap: () {
                      scaffoldKey.currentState?.closeDrawer();
                      NavigationService.goToSettings();
                    },
                  ),

                  _buildDrawerItem(
                    icon: Icons.privacy_tip,
                    title: 'Privacy Policy',
                    onTap: () {
                      scaffoldKey.currentState?.closeDrawer();
                      NavigationService.goToPrivacyPolicy();
                    },
                  ),

                  _buildDrawerItem(
                    icon: Icons.description,
                    title: 'Terms & Conditions',
                    onTap: () {
                      scaffoldKey.currentState?.closeDrawer();
                      NavigationService.goToTerms();
                    },
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(color: Constants.dividerColor),
                  ),

                  // Logout Button - Added in drawer
                  _buildDrawerItem(
                    icon: Icons.logout,
                    title: 'Logout',
                    onTap: () {
                      scaffoldKey.currentState?.closeDrawer();
                      _showLogoutDialog();
                    },
                  ),
                ],
              ),
            ),

            // Profile Section at Bottom
            _buildProfileSection(viewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(ChatViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Constants.primaryColor.withOpacity(0.1),
        border: Border(bottom: BorderSide(color: Constants.dividerColor)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Constants.primaryColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.psychology, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MindSpace',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Constants.textColor,
                  ),
                ),
                Obx(() {
                  return Text(
                    viewModel.isGuestMode.value ? 'Guest Mode' : 'Premium User',
                    style: TextStyle(
                      fontSize: 12,
                      color: Constants.textColor.withOpacity(0.7),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Constants.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Constants.primaryColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Constants.textColor,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Constants.textColor.withOpacity(0.5),
      ),
      onTap: onTap,
    );
  }

  Widget _buildProfileSection(ChatViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Constants.primaryColor.withOpacity(0.05),
        border: Border(top: BorderSide(color: Constants.dividerColor)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Constants.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Constants.primaryColor.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.person,
              color: Constants.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'User Profile',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Constants.textColor,
                  ),
                ),
                Obx(() {
                  return Text(
                    viewModel.isGuestMode.value ? 'Guest User' : 'Premium User',
                    style: TextStyle(
                      fontSize: 12,
                      color: Constants.textColor.withOpacity(0.7),
                    ),
                  );
                }),
              ],
            ),
          ),

          IconButton(
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Constants.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                Icons.arrow_forward,
                color: Constants.primaryColor,
                size: 18,
              ),
            ),
            onPressed: () {
              scaffoldKey.currentState?.closeDrawer();
              NavigationService.goToProfile();
            },
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    final ChatViewModel viewModel = Get.find<ChatViewModel>();

    Get.dialog(
      AlertDialog(
        title: const Text(
          'Logout',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Constants.textColor,
          ),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(fontSize: 16, color: Constants.textColor),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(fontSize: 16, color: Constants.textColor),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              viewModel.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Constants.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }
}
