import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Binding/AppBinding';
import 'Views/Login/Login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'EmoAssist',
      initialBinding: AppBinding(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Login(), // Start with Login screen
      debugShowCheckedModeBanner: false,
    );
  }
}