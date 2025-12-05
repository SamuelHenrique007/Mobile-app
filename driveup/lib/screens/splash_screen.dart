import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:driveup/navigation/main_navigation.dart';
import 'package:driveup/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // espera 2 segundos e decide o próximo passo
    Timer(const Duration(seconds: 2), _decideNext);
  }

  Future<void> _decideNext() async {
    final user = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    if (user != null) {
      // já está logado -> vai pro app principal
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    } else {
      // não logado -> vai pro login
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
      // ou: Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 👇 fundo branco em vez de preto
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/driveup_logo.png', width: 120),
            const SizedBox(height: 16),
            const Text(
              'DriveUP',
              style: TextStyle(
                color: Color(0xFFFFC107),
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Color(0xFFFFC107)),
            ),
          ],
        ),
      ),
    );
  }
}
