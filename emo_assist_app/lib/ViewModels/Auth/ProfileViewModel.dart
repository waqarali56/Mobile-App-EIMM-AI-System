// ViewModels/ProfileViewModel.dart
import 'package:get/get.dart';

class ProfileViewModel extends GetxController {
  // User Information
  final RxString userName = 'John Doe'.obs;
  final RxString userEmail = 'john.doe@example.com'.obs;
  final RxString memberSince = 'January 2024'.obs;
  final RxString lastActive = 'Just now'.obs;
  
  // Account Status
  final RxBool isPremium = false.obs;
  final RxBool isEditing = false.obs;
  
  // Statistics
  final RxInt totalConversations = 47.obs;
  final RxInt totalMessages = 324.obs;
  final RxInt totalSessions = 89.obs;
  
  void toggleEditMode() {
    isEditing.value = !isEditing.value;
  }
  
  void updateUserName(String newName) {
    userName.value = newName;
  }
  
  void updateUserEmail(String newEmail) {
    userEmail.value = newEmail;
  }
  
  void upgradeToPremium() {
    isPremium.value = true;
  }
  
  void deleteAccount() {
    // In a real app, this would call an API to delete the account
    // For now, just reset to default values
    userName.value = '';
    userEmail.value = '';
    isPremium.value = false;
    totalConversations.value = 0;
    totalMessages.value = 0;
    totalSessions.value = 0;
  }
}