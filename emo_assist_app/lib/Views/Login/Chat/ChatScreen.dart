import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Resources/Constants.dart';

class Chat extends StatelessWidget {
  const Chat({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EmoAssist Chat'),
        backgroundColor: Constants.primaryColor, // ✅ Fixed: Use static constant
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Chat Screen - Coming Soon'),
      ),
    );
  }
}