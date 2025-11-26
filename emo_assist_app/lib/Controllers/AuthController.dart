import 'package:get/get.dart';
import '../Enums/AppEnums.dart';
import '../Models/User.dart';
import '../Services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  
  final Rx<AuthStatus> status = AuthStatus.initial.obs;
  final Rx<User?> currentUser = Rx<User?>(null);
  final RxString errorMessage = ''.obs;
  final RxBool rememberMe = false.obs;

  Future<void> login(String email, String password) async {
    status.value = AuthStatus.loading;
    errorMessage.value = '';

    final response = await _authService.login(email, password);
    
    if (response.success) {
      currentUser.value = response.data;
      status.value = AuthStatus.success;
      
      // Store login state if remember me is enabled
      if (rememberMe.value) {
        // TODO: Store user session
      }
    } else {
      errorMessage.value = response.message!;
      status.value = AuthStatus.error;
    }
  }

  Future<void> signup(Map<String, dynamic> userData) async {
    status.value = AuthStatus.loading;
    errorMessage.value = '';

    final response = await _authService.signup(userData);
    
    if (response.success) {
      currentUser.value = response.data;
      status.value = AuthStatus.success;
    } else {
      errorMessage.value = response.message!;
      status.value = AuthStatus.error;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    currentUser.value = null;
    status.value = AuthStatus.initial;
  }

  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
  }

  bool get isLoggedIn => currentUser.value != null;
  bool get isLoading => status.value == AuthStatus.loading;
}