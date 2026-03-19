// Views/Profile/ProfileScreen.dart
import 'package:emo_assist_app/ViewModels/Auth/ProfileViewModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emo_assist_app/Resources/Constants.dart';
import 'package:emo_assist_app/Services/navigation_service.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final ProfileViewModel viewModel = Get.find<ProfileViewModel>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Constants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        title: const Text(
          'Profile',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => NavigationService.goBack(),
        ),
        // 🟢 REMOVED: Edit button action
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Header
          _buildProfileHeader(),

          const SizedBox(height: 24),

          // Personal Information
          _buildSectionTitle('Personal Information'),
          _buildInfoCard(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Obx(() {
      return Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Constants.primaryColor.withOpacity(0.2),
                  border: Border.all(
                    color: Constants.primaryColor,
                    width: 3,
                  ),
                ),
                child: Icon(
                  Icons.person,
                  size: 60,
                  color: Constants.primaryColor,
                ),
              ),
              // 🟢 REMOVED: Camera icon for editing profile picture
            ],
          ),
          const SizedBox(height: 16),
          // 🟢 REMOVED: Edit mode name field - always display name only
          Text(
            viewModel.userName.value.isNotEmpty
                ? viewModel.userName.value
                : 'User',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Constants.textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            viewModel.userEmail.value.isNotEmpty
                ? viewModel.userEmail.value
                : 'Not logged in',
            style: TextStyle(
              fontSize: 14,
              color: Constants.textColor.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
        ],
      );
    });
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Constants.textColor,
            ),
          ),
        ));
  }

  Widget _buildInfoCard() {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Constants.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Constants.dividerColor),
        ),
        child: Column(
          children: [
            _buildInfoRow(
              icon: Icons.person,
              label: 'Username',
              value: viewModel.userName.value.isNotEmpty
                  ? viewModel.userName.value
                  : '—',
            ),
            const Divider(color: Constants.dividerColor),
            _buildInfoRow(
              icon: Icons.email,
              label: 'Email',
              value: viewModel.userEmail.value.isNotEmpty
                  ? viewModel.userEmail.value
                  : '—',
            ),
            const Divider(color: Constants.dividerColor),
            _buildInfoRow(
              icon: Icons.update,
              label: 'Last Active',
              value: viewModel.lastActive.value,
            ),
            const Divider(color: Constants.dividerColor),
          ],
        ),
      );
    });
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Constants.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
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
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Constants.textColor.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Constants.textColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  // 🟢 REMOVED: _toggleEditMode method
  // 🟢 REMOVED: _saveChanges method
  // 🟢 REMOVED: _changeProfilePicture method
}
