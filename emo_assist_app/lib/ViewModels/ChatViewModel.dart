// lib/ViewModels/ChatViewModel.dart
import 'package:emo_assist_app/Resources/app_routes.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:emo_assist_app/ViewModels/AuthViewModel.dart';

class ChatViewModel extends GetxController {
  final RxList<String> messages = <String>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isGuestMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkUserStatus();
  }

  Future<void> _checkUserStatus() async {
    isLoading.value = true;
    
    final prefs = await SharedPreferences.getInstance();
    isGuestMode.value = prefs.getBool('is_guest') ?? false;
    
    isLoading.value = false;
  }

  void sendMessage(String message) {
    if (message.trim().isEmpty) return;
    
    messages.add('You: $message');
    
    // Simulate AI response
    Future.delayed(const Duration(seconds: 1), () {
      messages.add('EmoAssist: Thanks for sharing! How can I help you today?');
    });
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (isGuestMode.value) {
      await prefs.remove('is_guest');
      AppRoutes.goToLogin();  // CHANGED
    } else {
      final authViewModel = Get.find<AuthViewModel>();
      await authViewModel.logout();
      // logout() in AuthViewModel already calls AppRoutes.goToLogin()
    }
  }
}