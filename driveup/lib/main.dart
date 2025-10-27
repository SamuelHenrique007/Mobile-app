import 'package:driveup/screens/splash_screen.dart';
import 'package:flutter/material.dart';
//import 'screens/login_screen.dart';
//import 'screens/cadastro_page.dart';
//import 'screens/home_screen.dart';
//import 'screens/cadastro_confirm_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
