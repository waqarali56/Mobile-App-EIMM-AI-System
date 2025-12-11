// Screens/Drawer/TermsScreen.dart
import 'package:flutter/material.dart';
import 'package:emo_assist_app/Resources/Constants.dart';
import 'package:emo_assist_app/Services/navigation_service.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Constants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Terms & Conditions',
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
          // Important Notice Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.amber.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.amber,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Important Notice',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Constants.textColor,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Please read these terms carefully before using MindSpace. Your continued use of the service constitutes acceptance of these terms.',
                        style: TextStyle(
                          fontSize: 13.5,
                          color: Constants.textColor.withOpacity(0.8),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Welcome Header
          _buildSectionHeader('Terms of Service'),
          const SizedBox(height: 8),
          _buildParagraph(
            'Welcome to MindSpace. These Terms & Conditions govern your use of our AI-powered emotional support platform. By accessing or using our services, you agree to be bound by these terms.',
          ),

          const SizedBox(height: 24),

          // Acceptance of Terms
          _buildSectionTitle('1. Acceptance of Terms', Icons.gavel_rounded),
          const SizedBox(height: 8),
          _buildParagraph(
            'By accessing and using MindSpace, you accept and agree to be bound by the terms and provisions of this agreement. If you do not agree to these terms, please do not use our services.',
          ),

          Divider(
            height: 40,
            color: Constants.dividerColor.withOpacity(0.3),
            thickness: 1,
          ),

          // Description of Service
          _buildSectionTitle(
            '2. Description of Service',
            Icons.psychology_rounded,
          ),
          const SizedBox(height: 8),
          _buildParagraph(
            'MindSpace provides AI-powered emotional support and mental wellness services through intelligent chat-based interactions. Our platform uses advanced AI to offer personalized support and guidance.',
          ),

          const SizedBox(height: 24),

          // User Responsibilities
          _buildSectionTitle(
            '3. User Responsibilities',
            Icons.account_circle_rounded,
          ),
          const SizedBox(height: 12),
          _buildBulletPoint(
            'Use the service for personal, non-commercial purposes only',
          ),
          _buildBulletPoint(
            'Provide accurate and truthful information in your interactions',
          ),
          _buildBulletPoint(
            'Do not misuse, exploit, or attempt to manipulate the service',
          ),
          _buildBulletPoint(
            'Maintain the confidentiality of your account credentials',
          ),
          _buildBulletPoint('Respect the AI system and use it as intended'),

          const SizedBox(height: 24),

          // Intellectual Property
          _buildSectionTitle(
            '4. Intellectual Property',
            Icons.copyright_rounded,
          ),
          const SizedBox(height: 8),
          _buildParagraph(
            'All content, features, and functionality of MindSpace (including but not limited to text, graphics, logos, icons, and software) are the exclusive property of MindSpace Inc. and are protected by international copyright, trademark, patent, trade secret, and other intellectual property laws.',
          ),

          const SizedBox(height: 24),

          // Important Disclaimer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.red.withOpacity(0.1),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.medical_services_rounded,
                      color: Colors.red.withOpacity(0.8),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Important Medical Disclaimer',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.red.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'MindSpace is not a substitute for professional medical advice, diagnosis, or treatment. Always seek the advice of qualified health providers with any questions you may have regarding medical or mental health conditions.',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: Colors.red.withOpacity(0.7),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Disclaimer of Warranties
          _buildSectionTitle(
            '5. Disclaimer of Warranties',
            Icons.verified_user_rounded,
          ),
          const SizedBox(height: 8),
          _buildParagraph(
            'The service is provided "as is" and "as available" without any warranties of any kind, either express or implied, including but not limited to implied warranties of merchantability, fitness for a particular purpose, or non-infringement.',
          ),

          const SizedBox(height: 24),

          // Limitation of Liability
          _buildSectionTitle(
            '6. Limitation of Liability',
            Icons.balance_rounded,
          ),
          const SizedBox(height: 8),
          _buildParagraph(
            'In no event shall MindSpace, its directors, employees, partners, agents, suppliers, or affiliates be liable for any indirect, incidental, special, consequential, or punitive damages, including without limitation, loss of profits, data, use, goodwill, or other intangible losses, resulting from your access to or use of or inability to access or use the service.',
          ),

          const SizedBox(height: 24),

          // Changes to Terms
          _buildSectionTitle(
            '7. Changes to Terms',
            Icons.edit_calendar_rounded,
          ),
          const SizedBox(height: 8),
          _buildParagraph(
            'We reserve the right to modify or replace these terms at any time. If a revision is material, we will provide at least 30 days notice prior to any new terms taking effect. What constitutes a material change will be determined at our sole discretion.',
          ),

          const SizedBox(height: 24),

          // Governing Law
          _buildSectionTitle('8. Governing Law', Icons.balance_rounded),
          const SizedBox(height: 8),
          _buildParagraph(
            'These terms shall be governed by and construed in accordance with the laws of the State of California, without regard to its conflict of law provisions. Any disputes arising under these terms shall be resolved in the appropriate courts located in San Francisco County, California.',
          ),

          const SizedBox(height: 28),

          // Contact Information Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Constants.cardColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Constants.dividerColor.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.contact_support_rounded,
                      color: Constants.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Contact Information',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Constants.textColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildParagraph(
                  'For any questions about these Terms & Conditions, please contact our legal department:',
                ),
                const SizedBox(height: 16),
                _buildContactInfoCard(
                  'Email Address',
                  'legal@mindspace.com',
                  Icons.email_rounded,
                ),
                const SizedBox(height: 12),
                _buildContactInfoCard(
                  'Phone Number',
                  '+1 (555) 123-4567',
                  Icons.phone_rounded,
                ),
                const SizedBox(height: 12),
                _buildContactInfoCard(
                  'Business Hours',
                  'Mon-Fri, 9:00 AM - 5:00 PM PST',
                  Icons.access_time_rounded,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Agreement Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Constants.primaryColor.withOpacity(0.08),
                  Constants.primaryColor.withOpacity(0.03),
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
                Icon(
                  Icons.assignment_turned_in_rounded,
                  size: 36,
                  color: Constants.primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Agreement Acknowledgment',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Constants.textColor,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'By using MindSpace, you acknowledge that you have read, understood, and agree to be bound by these Terms & Conditions. Your continued use of the service constitutes ongoing acceptance.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Constants.textColor.withOpacity(0.7),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 16),
                Divider(
                  color: Constants.dividerColor.withOpacity(0.3),
                  thickness: 1,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.update_rounded,
                      size: 16,
                      color: Constants.textColor.withOpacity(0.6),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Last Updated: January 1, 2024',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Constants.textColor.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Footer
          Center(
            child: Text(
              'MindSpace Inc. © 2024. All rights reserved.',
              style: TextStyle(
                fontSize: 12,
                color: Constants.textColor.withOpacity(0.5),
              ),
            ),
          ),
          const SizedBox(height: 20),
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
      padding: const EdgeInsets.only(left: 8, bottom: 10),
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

  Widget _buildContactInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Constants.dividerColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Constants.textColor.withOpacity(0.6)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
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
