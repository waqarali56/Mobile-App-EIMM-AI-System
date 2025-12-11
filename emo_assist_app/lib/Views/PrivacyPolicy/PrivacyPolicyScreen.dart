// Screens/Drawer/PrivacyPolicyScreen.dart
import 'package:flutter/material.dart';
import 'package:emo_assist_app/Resources/Constants.dart';
import 'package:emo_assist_app/Services/navigation_service.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Constants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Last Updated Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Constants.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Constants.primaryColor.withOpacity(0.1),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Constants.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.update_rounded,
                    color: Constants.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Last Updated',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Constants.textColor.withOpacity(0.6),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'January 1, 2024',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Constants.textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Welcome Text
          _buildSectionHeader('Your Privacy Matters'),
          const SizedBox(height: 8),
          _buildParagraph(
            'Welcome to MindSpace. We are committed to protecting your privacy and ensuring that your personal information is handled with the utmost care and responsibility.',
          ),

          Divider(
            height: 40,
            color: Constants.dividerColor.withOpacity(0.3),
            thickness: 1,
          ),

          // Information We Collect
          _buildSectionTitle(
            '1. Information We Collect',
            Icons.collections_bookmark_rounded,
          ),
          const SizedBox(height: 12),
          _buildBulletPoint('Account information (email, name)'),
          _buildBulletPoint('Chat conversations and emotional data'),
          _buildBulletPoint('Device information and usage analytics'),
          _buildBulletPoint('Multi-modal data (with your consent)'),

          const SizedBox(height: 24),

          // How We Use Your Information
          _buildSectionTitle(
            '2. How We Use Your Information',
            Icons.insights_rounded,
          ),
          const SizedBox(height: 12),
          _buildBulletPoint('Provide personalized emotional support'),
          _buildBulletPoint('Improve our AI models and services'),
          _buildBulletPoint('Ensure security and prevent fraud'),
          _buildBulletPoint('Communicate updates and support'),

          const SizedBox(height: 24),

          // Data Security
          _buildSectionTitle('3. Data Security', Icons.shield_rounded),
          const SizedBox(height: 12),
          _buildParagraph(
            'We implement enterprise-grade security measures to protect your data. All communications are encrypted using TLS 1.3, and sensitive data is anonymized using state-of-the-art techniques to ensure your privacy.',
          ),

          const SizedBox(height: 24),

          // Your Rights
          _buildSectionTitle('4. Your Rights', Icons.gavel_rounded),
          const SizedBox(height: 12),
          _buildBulletPoint('Access your personal data'),
          _buildBulletPoint('Request data deletion'),
          _buildBulletPoint('Opt-out of data collection'),
          _buildBulletPoint('Export your chat history'),

          const SizedBox(height: 24),

          // Contact Information
          _buildSectionTitle(
            '5. Contact Information',
            Icons.contact_support_rounded,
          ),
          const SizedBox(height: 12),
          _buildParagraph(
            'If you have any questions or concerns about our Privacy Policy, our team is here to help:',
          ),
          const SizedBox(height: 16),
          _buildContactCard(
            icon: Icons.email_rounded,
            title: 'Email Address',
            value: 'privacy@mindspace.com',
            color: Colors.blue.withOpacity(0.1),
          ),
          const SizedBox(height: 8),
          _buildContactCard(
            icon: Icons.location_on_rounded,
            title: 'Office Address',
            value: '123 MindSpace St, Tech City, TC 10001',
            color: Colors.green.withOpacity(0.1),
          ),

          const SizedBox(height: 32),

          // Consent Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Constants.primaryColor.withOpacity(0.05),
                  Constants.primaryColor.withOpacity(0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Constants.primaryColor.withOpacity(0.15),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Constants.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.privacy_tip_rounded,
                    size: 32,
                    color: Constants.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Your Privacy, Our Priority',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Constants.textColor,
                    letterSpacing: -0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'By using MindSpace, you acknowledge that you have read and understood this Privacy Policy and consent to our data practices.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Constants.textColor.withOpacity(0.7),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Footer
          Center(
            child: Text(
              '© 2024 MindSpace. All rights reserved.',
              style: TextStyle(
                fontSize: 12,
                color: Constants.textColor.withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Constants.textColor,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Constants.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: Constants.primaryColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Constants.textColor,
              letterSpacing: -0.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15,
        color: Constants.textColor.withOpacity(0.8),
        height: 1.6,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5, right: 12),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: Constants.primaryColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: Constants.textColor.withOpacity(0.8),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Constants.textColor.withOpacity(0.7)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Constants.textColor.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Constants.textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
