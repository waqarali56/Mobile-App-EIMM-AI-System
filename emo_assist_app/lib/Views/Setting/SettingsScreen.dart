// Screens/Drawer/SettingsScreen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emo_assist_app/Resources/Constants.dart';
import 'package:emo_assist_app/Services/navigation_service.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  final RxBool notifications = true.obs;
  final RxBool darkMode = false.obs;
  final RxBool autoSave = true.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Constants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        title: const Text(
          'Settings',
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
          // Account Section
          _buildSectionTitle('Account'),

          _buildSettingItem(
            icon: Icons.security,
            title: 'Privacy & Security',
            onTap: () => NavigationService.goToPrivacyPolicy(),
          ),
          _buildSettingItem(
            icon: Icons.language,
            title: 'Language',
            subtitle: 'English',
            onTap: _showLanguageOptions,
          ),

          // App Preferences
          const SizedBox(height: 24),
          _buildSectionTitle('App Preferences'),

          Obx(
            () => _buildSwitchSetting(
              icon: Icons.dark_mode,
              title: 'Dark Mode',
              value: darkMode.value,
              onChanged: (val) => darkMode.value = val,
            ),
          ),
          Obx(
            () => _buildSwitchSetting(
              icon: Icons.save,
              title: 'Auto-save Chats',
              value: autoSave.value,
              onChanged: (val) => autoSave.value = val,
            ),
          ),

          // Support
          const SizedBox(height: 24),
          _buildSectionTitle('Support'),
          _buildSettingItem(
            icon: Icons.help,
            title: 'Help Center',
            onTap: _showHelpCenter,
          ),
          _buildSettingItem(
            icon: Icons.feedback,
            title: 'Send Feedback',
            onTap: _sendFeedback,
          ),
          _buildSettingItem(
            icon: Icons.star,
            title: 'Rate App',
            onTap: _rateApp,
          ),

          // About
          const SizedBox(height: 24),
          _buildSectionTitle('About'),
          _buildSettingItem(
            icon: Icons.info,
            title: 'About MindSpace',
            onTap: _showAbout,
          ),
          _buildSettingItem(
            icon: Icons.update,
            title: 'App Version',
            subtitle: 'Version 1.0.0',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Constants.textColor.withOpacity(0.7),
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
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
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Constants.textColor.withOpacity(0.6),
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right,
        color: Constants.textColor.withOpacity(0.4),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
    );
  }

  Widget _buildSwitchSetting({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
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
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Constants.primaryColor,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
    );
  }

  void _showLanguageOptions() {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Constants.cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Language',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Constants.textColor,
              ),
            ),
            const SizedBox(height: 20),
            _buildLanguageOption('English', true),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Constants.primaryColor,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Apply',
                style: const TextStyle(
                  color: Colors.white, // 👈 Add this line
                  // other styles...
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String language, bool selected) {
    return ListTile(
      title: Text(
        language,
        style: TextStyle(
          fontSize: 16,
          color: selected ? Constants.primaryColor : Constants.textColor,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: selected
          ? Icon(Icons.check_circle, color: Constants.primaryColor)
          : null,
      onTap: () {
        Get.back();
        Get.snackbar(
          'Language Changed',
          'App language set to $language',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }

  void _showHelpCenter() {
    Get.snackbar(
      'Help Center',
      'Opening help center...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _sendFeedback() {
    Get.snackbar(
      'Send Feedback',
      'Feedback feature coming soon!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _rateApp() {
    Get.snackbar(
      'Rate App',
      'Rating feature coming soon!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showAbout() {
    Get.dialog(
      AlertDialog(
        title: const Text(
          'About MindSpace',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Constants.textColor,
          ),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version 1.0.0',
              style: TextStyle(fontSize: 14, color: Constants.textColor),
            ),
            SizedBox(height: 8),
            Text(
              'MindSpace is your emotional support companion that helps you understand and manage your emotions through AI-powered conversations.',
              style: TextStyle(fontSize: 14, color: Constants.textColor),
            ),
            SizedBox(height: 8),
            Text(
              '© 2024 MindSpace Technologies. All rights reserved.',
              style: TextStyle(fontSize: 12, color: Constants.textColor),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }
}
