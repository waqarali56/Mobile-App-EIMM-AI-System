// Views/OTPVerificationScreen.dart
import 'package:emo_assist_app/Models/OTP.dart';
import 'package:emo_assist_app/ViewModels/Auth/OTPViewModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emo_assist_app/Resources/Constants.dart';
import 'package:emo_assist_app/Enums/AppEnums.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String email;
  final OTPType type;

  const OTPVerificationScreen({
    super.key,
    required this.email,
    this.type = OTPType.EmailVerification,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  late OTPViewModel viewModel;
  List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());

  @override
  void initState() {
    super.initState();
    viewModel = Get.find<OTPViewModel>();
    // Initialize with email from route or widget parameter
    String email = widget.email;

    // If email is empty from route, try to get from Get parameters
    if (email.isEmpty) {
      final routeEmail = Get.parameters['email'];
      if (routeEmail != null && routeEmail.isNotEmpty) {
        email = routeEmail;
      }
    }

    // If still empty, try to get from arguments
    if (email.isEmpty) {
      final arguments = Get.arguments;
      if (arguments is Map && arguments['email'] != null) {
        email = arguments['email'];
      }
    }

    // Get OTP type
    OTPType type = widget.type;
    final routeType = Get.parameters['type'];
    if (routeType != null) {
      type = OTPType.values.firstWhere(
        (e) => e.toString().split('.').last == routeType,
        orElse: () => OTPType.EmailVerification,
      );
    }

    // Initialize ViewModel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (email.isNotEmpty) {
        viewModel.initialize(email, type);
      } else {
        Get.snackbar('Error', 'Email not found');
        Get.back();
      }
    });
  }

  @override
  void dispose() {
    for (var focusNode in focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          viewModel.type == OTPType.EmailVerification
              ? 'Verify Email'
              : 'Reset Password',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => viewModel.navigateBack(),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Title
              Text(
                'Verification Code',
                style: Constants.headlineMedium.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // Description
              Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'We have sent a 6-digit OTP to:',
                      style: Constants.bodyMedium.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        viewModel.email.isNotEmpty
                            ? viewModel.email
                            : 'Loading...',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Please enter the code below to continue.',
                      style: Constants.bodyMedium.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Error message
              Obx(() {
                if (viewModel.errorMessage.isNotEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            viewModel.errorMessage,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox();
              }),

              // OTP Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 50,
                    child: TextFormField(
                      focusNode: focusNodes[index],
                      controller: TextEditingController(
                        text: viewModel.otpDigits[index],
                      ),
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.length == 1 && index < 5) {
                          FocusScope.of(
                            context,
                          ).requestFocus(focusNodes[index + 1]);
                        } else if (value.isEmpty && index > 0) {
                          FocusScope.of(
                            context,
                          ).requestFocus(focusNodes[index - 1]);
                        }
                        viewModel.updateOTP(index, value);
                      },
                    ),
                  );
                }),
              ),

              const SizedBox(height: 30),

              // Timer
              Obx(
                () => Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.timer_outlined),
                      const SizedBox(width: 10),
                      Text(
                        'Resend code in: ${viewModel.countdown}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Resend button
              Obx(
                () => Center(
                  child: ElevatedButton(
                    onPressed: viewModel.canResend ? viewModel.resendOTP : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: viewModel.canResend
                          ? Colors.blue
                          : Colors.grey,
                    ),
                    child: const Text('Resend OTP'),
                  ),
                ),
              ),

              const Spacer(),

              // Verify button
              SizedBox(
                width: double.infinity,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: viewModel.canVerify ? viewModel.verifyOTP : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: viewModel.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            viewModel.type == OTPType.EmailVerification
                                ? 'Verify Email'
                                : 'Reset Password',
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
