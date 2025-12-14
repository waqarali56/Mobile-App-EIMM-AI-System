// Views/Profile/ProfileScreen.dart
import 'package:emo_assist_app/ViewModels/Auth/ProfileViewModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emo_assist_app/Resources/Constants.dart';
import 'package:emo_assist_app/Services/navigation_service.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final ProfileViewModel viewModel = Get.find<ProfileViewModel>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

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
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _toggleEditMode,
            tooltip: 'Edit Profile',
          ),
        ],
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
          
          // Account Status
          _buildSectionTitle('Account Status'),
          _buildAccountStatus(),
          
          const SizedBox(height: 24),
          
          // Statistics
          _buildSectionTitle('Your Statistics'),
          _buildStatistics(),
          
          const SizedBox(height: 32),
          
          // Action Buttons
          _buildActionButtons(),
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
              if (viewModel.isEditing.value)
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Constants.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                    onPressed: _changeProfilePicture,
                    padding: EdgeInsets.zero,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (viewModel.isEditing.value) {
              return SizedBox(
                width: 200,
                child: TextField(
                  controller: _nameController,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Constants.textColor,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter your name',
                    hintStyle: TextStyle(
                      color: Constants.textColor.withOpacity(0.5),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              );
            }
            return Text(
              viewModel.userName.value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Constants.textColor,
              ),
            );
          }),
          Obx(() => Text(
            viewModel.userEmail.value,
            style: TextStyle(
              fontSize: 14,
              color: Constants.textColor.withOpacity(0.7),
            ),
          )),
          const SizedBox(height: 8),
          Obx(() => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: viewModel.isPremium.value
                  ? Colors.amber.withOpacity(0.1)
                  : Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: viewModel.isPremium.value
                    ? Colors.amber.withOpacity(0.3)
                    : Colors.blue.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  viewModel.isPremium.value
                      ? Icons.star
                      : Icons.person_outline,
                  size: 12,
                  color: viewModel.isPremium.value ? Colors.amber : Colors.blue,
                ),
                const SizedBox(width: 4),
                Text(
                  viewModel.isPremium.value ? 'Premium User' : 'Basic User',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: viewModel.isPremium.value ? Colors.amber : Colors.blue,
                  ),
                ),
              ],
            ),
          )),
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
      )
    );
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
              icon: Icons.email,
              label: 'Email',
              value: viewModel.userEmail.value,
              isEditing: viewModel.isEditing.value,
              controller: _emailController,
            ),
            const Divider(color: Constants.dividerColor),
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: 'Member Since',
              value: viewModel.memberSince.value,
            ),
            const Divider(color: Constants.dividerColor),
            _buildInfoRow(
              icon: Icons.update,
              label: 'Last Active',
              value: viewModel.lastActive.value,
            ),
            const Divider(color: Constants.dividerColor),
            _buildInfoRow(
              icon: Icons.chat,
              label: 'Total Conversations',
              value: viewModel.totalConversations.value.toString(),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isEditing = false,
    TextEditingController? controller,
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
                if (isEditing && controller != null)
                  TextField(
                    controller: controller,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Constants.textColor,
                    ),
                    decoration: InputDecoration(
                      hintText: value,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  )
                else
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
      )
    );
  }

  Widget _buildAccountStatus() {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: viewModel.isPremium.value
              ? Colors.amber.withOpacity(0.05)
              : Constants.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: viewModel.isPremium.value
                ? Colors.amber.withOpacity(0.3)
                : Constants.dividerColor,
          ),
        ),
        child: Row(
          children: [
            Icon(
              viewModel.isPremium.value ? Icons.star : Icons.person_outline,
              color: viewModel.isPremium.value ? Colors.amber : Constants.primaryColor,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    viewModel.isPremium.value ? 'Premium Account' : 'Basic Account',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: viewModel.isPremium.value ? Colors.amber : Constants.textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    viewModel.isPremium.value
                        ? 'Full access to all features'
                        : 'Upgrade for multi-modal features',
                    style: TextStyle(
                      fontSize: 12,
                      color: Constants.textColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (!viewModel.isPremium.value)
              ElevatedButton(
                onPressed: _upgradeToPremium,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('Upgrade'),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildStatistics() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Constants.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Constants.dividerColor),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('Total Chats', '47', Icons.chat),
              _buildStatItem('Avg. Sessions', '12 min', Icons.timer),
              _buildStatItem('Emotions', '8', Icons.emoji_emotions),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('Words Used', '2.4K', Icons.text_fields),
              _buildStatItem('Active Days', '24', Icons.calendar_month),
              _buildStatItem('Goals', '3', Icons.flag),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Constants.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Icon(
            icon,
            color: Constants.primaryColor,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Constants.textColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Constants.textColor.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Obx(() {
      if (viewModel.isEditing.value) {
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _toggleEditMode,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Constants.textColor,
                  side: BorderSide(color: Constants.dividerColor),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Cancel'),
              ),
            ),
          ],
        );
      }
      
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _toggleEditMode,
              style: OutlinedButton.styleFrom(
                foregroundColor: Constants.primaryColor,
                side: BorderSide(color: Constants.primaryColor),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Edit Profile'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _deleteAccount,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: BorderSide(color: Colors.red.withOpacity(0.3)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Delete Account'),
            ),
          ),
        ],
      );
    });
  }

  void _toggleEditMode() {
    viewModel.toggleEditMode();
    if (viewModel.isEditing.value) {
      _nameController.text = viewModel.userName.value;
      _emailController.text = viewModel.userEmail.value;
    }
  }

  void _saveChanges() {
    if (_nameController.text.isNotEmpty) {
      viewModel.updateUserName(_nameController.text);
    }
    if (_emailController.text.isNotEmpty) {
      viewModel.updateUserEmail(_emailController.text);
    }
    viewModel.toggleEditMode();
    Get.snackbar(
      'Success',
      'Profile updated successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Constants.primaryColor,
      colorText: Colors.white,
    );
  }

  void _changeProfilePicture() {
    Get.snackbar(
      'Change Profile Picture',
      'Feature coming soon!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _upgradeToPremium() {
    Get.defaultDialog(
      title: 'Upgrade to Premium',
      titleStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Constants.textColor,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPremiumFeature('Voice tone analysis'),
          _buildPremiumFeature('Facial expression recognition'),
          _buildPremiumFeature('Advanced emotional insights'),
          _buildPremiumFeature('Priority support'),
          _buildPremiumFeature('Unlimited chat history'),
          const SizedBox(height: 16),
          const Text(
            'Only \$9.99/month',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Constants.primaryColor,
            ),
          ),
        ],
      ),
      textConfirm: 'Subscribe Now',
      textCancel: 'Maybe Later',
      confirmTextColor: Colors.white,
      cancelTextColor: Constants.textColor,
      buttonColor: Constants.primaryColor,
      onConfirm: () {
        Get.back();
        viewModel.upgradeToPremium();
        Get.snackbar(
          'Success',
          'Welcome to Premium!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Constants.primaryColor,
          colorText: Colors.white,
        );
      },
    );
  }

  Widget _buildPremiumFeature(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Constants.primaryColor,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            feature,
            style: const TextStyle(
              fontSize: 14,
              color: Constants.textColor,
            ),
          ),
        ],
      )
    );
  }

  void _deleteAccount() {
    Get.dialog(
      AlertDialog(
        title: const Text(
          'Delete Account',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete your account?',
              style: TextStyle(fontSize: 16, color: Constants.textColor),
            ),
            SizedBox(height: 8),
            Text(
              'This action cannot be undone. All your data including chat history will be permanently deleted.',
              style: TextStyle(fontSize: 14, color: Constants.textColor),
            ),
          ],
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
              viewModel.deleteAccount();
              NavigationService.goToLogin();
              Get.snackbar(
                'Account Deleted',
                'Your account has been successfully deleted',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Delete Account',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }
}