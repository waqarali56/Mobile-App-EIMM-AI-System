// ViewModels/ProfileViewModel.dart
import 'package:emo_assist_app/Models/User.dart';
import 'package:emo_assist_app/ViewModels/Auth/AuthViewModel.dart';
import 'package:get/get.dart';

class ProfileViewModel extends GetxController {
  // User Information (synced from AuthViewModel when logged in)
  final RxString userName = ''.obs;
  final RxString userEmail = ''.obs;
  final RxString memberSince = ''.obs;
  final RxString lastActive = 'Just now'.obs;

  // Account Status
  final RxBool isPremium = false.obs;
  // 🟢 REMOVED: isEditing flag

  // Statistics (placeholders until backend provides them)
  final RxInt totalConversations = 0.obs;
  final RxInt totalMessages = 0.obs;
  final RxInt totalSessions = 0.obs;

  AuthViewModel get _authViewModel => Get.find<AuthViewModel>();

  @override
  void onInit() {
    super.onInit();
    _authViewModel.loadUserFromPreferences().then((_) => _syncFromCurrentUser());
    ever(_authViewModel.currentUser, (_) => _syncFromCurrentUser());
  }

  /// Sync profile display from the logged-in user (AuthService / AuthViewModel).
  void _syncFromCurrentUser() {
    final User? user = _authViewModel.currentUser.value;
    if (user != null) {
      userName.value = user.name.isNotEmpty ? user.name : 'User';
      userEmail.value = user.email;
      isPremium.value = user.isPremium;
      memberSince.value = _formatMemberSince(user.createdAt);
      // lastActive could be updated from API later
    } else {
      userName.value = '';
      userEmail.value = '';
      memberSince.value = '';
      isPremium.value = false;
    }
  }

  static const List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  String _formatMemberSince(DateTime? date) {
    if (date == null) return '';
    return '${_months[date.month - 1]} ${date.year}';
  }

 

  void deleteAccount() {
    userName.value = '';
    userEmail.value = '';
    isPremium.value = false;
    totalConversations.value = 0;
    totalMessages.value = 0;
    totalSessions.value = 0;
  }
}