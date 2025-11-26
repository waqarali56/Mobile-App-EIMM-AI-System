import 'package:get/get.dart';
import '../Controllers/AuthController.dart';
import '../Enums/AppEnums.dart';

class AuthViewModel extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  
  // Form fields
  final RxString email = ''.obs;
  final RxString password = ''.obs;
  final RxString confirmPassword = ''.obs;
  final RxString name = ''.obs;
  
  // Validation
  final RxString emailError = ''.obs;
  final RxString passwordError = ''.obs;
  final RxString confirmPasswordError = ''.obs;
  final RxString nameError = ''.obs;

  // Getters
  bool get isValidEmail => email.value.contains('@') && email.value.contains('.');
  bool get isValidPassword => password.value.length >= 6;
  bool get isValidConfirmPassword => password.value == confirmPassword.value;
  bool get isValidName => name.value.trim().isNotEmpty;
  
  bool get canLogin => isValidEmail && isValidPassword && emailError.isEmpty && passwordError.isEmpty;
  bool get canSignup => canLogin && isValidConfirmPassword && isValidName;

  // Add to your AuthViewModel if missing
Rx<AuthStatus> get status => _authController.status;
RxString get errorMessage => _authController.errorMessage;
bool get isLoading => _authController.isLoading;

  get rememberMe => null;

  // Actions
  void validateEmail() {
    if (email.value.isEmpty) {
      emailError.value = 'Email is required';
    } else if (!isValidEmail) {
      emailError.value = 'Please enter a valid email';
    } else {
      emailError.value = '';
    }
  }

  void validatePassword() {
    if (password.value.isEmpty) {
      passwordError.value = 'Password is required';
    } else if (!isValidPassword) {
      passwordError.value = 'Password must be at least 6 characters';
    } else {
      passwordError.value = '';
    }
  }

  void validateConfirmPassword() {
    if (confirmPassword.value.isEmpty) {
      confirmPasswordError.value = 'Please confirm your password';
    } else if (!isValidConfirmPassword) {
      confirmPasswordError.value = 'Passwords do not match';
    } else {
      confirmPasswordError.value = '';
    }
  }

  void validateName() {
    if (name.value.isEmpty) {
      nameError.value = 'Name is required';
    } else {
      nameError.value = '';
    }
  }

  Future<void> login() async {
    validateEmail();
    validatePassword();
    
    if (canLogin) {
      await _authController.login(email.value.trim(), password.value);
    }
  }

  Future<void> signup() async {
    validateEmail();
    validatePassword();
    validateConfirmPassword();
    validateName();
    
    if (canSignup) {
      final userData = {
        'email': email.value.trim(),
        'password': password.value,
        'name': name.value.trim(),
      };
      
      await _authController.signup(userData);
    }
  }

  void toggleRememberMe() {
    _authController.toggleRememberMe();
  }

  void clearForm() {
    email.value = '';
    password.value = '';
    confirmPassword.value = '';
    name.value = '';
    emailError.value = '';
    passwordError.value = '';
    confirmPasswordError.value = '';
    nameError.value = '';
  }
}