import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:driveup/services/auth_service.dart';

class CadastroConfirmPage extends StatefulWidget {
  const CadastroConfirmPage({super.key});

  @override
  State<CadastroConfirmPage> createState() => _CadastroConfirmPageState();
}

class _CadastroConfirmPageState extends State<CadastroConfirmPage> {
  final _authService = AuthService();
  bool _loadingVerificar = false;
  bool _loadingReenviar = false;

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  /// Botão "Já cliquei no link, continuar"
  Future<void> _verificar() async {
    setState(() => _loadingVerificar = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.reload();
        if (user.emailVerified) {
          _showSnack('E-mail verificado com sucesso!');
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          _showSnack(
            'E-mail ainda não verificado. Confira sua caixa de entrada.',
          );
        }
      } else {
        _showSnack('Nenhum usuário logado.');
      }
    } catch (e) {
      _showSnack('Erro ao verificar: $e');
    } finally {
      setState(() => _loadingVerificar = false);
    }
  }

  /// Botão "Reenviar e-mail de verificação"
  Future<void> _reenviarEmail() async {
    setState(() => _loadingReenviar = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
        _showSnack('E-mail de verificação reenviado!');
      } else {
        _showSnack('Nenhum usuário logado para reenviar o e-mail.');
      }
    } catch (e) {
      _showSnack('Erro ao reenviar e-mail: $e');
    } finally {
      setState(() => _loadingReenviar = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/driveup_logo.png', height: 120),
              const SizedBox(height: 10),
              const Text(
                'DriveUP',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFC107),
                ),
              ),
              const SizedBox(height: 25),

              const Text(
                'Enviamos um link de verificação para o seu e-mail.\n'
                'Clique no link que recebeu e depois toque em "Já cliquei no link".\n\n'
                'Se não recebeu, toque em "Reenviar e-mail".',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.black87),
              ),
              const SizedBox(height: 25),

              // Campo de código aqui é apenas estético
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F4F4),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Code - 77777 (visual)',
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Image.asset(
                        'assets/icons/email.png',
                        width: 20,
                        height: 20,
                        color: Colors.grey,
                      ),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(height: 30),

              // Botão "Já cliquei no link"
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _loadingVerificar ? null : _verificar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC107),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _loadingVerificar
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'JÁ CLIQUEI NO LINK',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),

              // Botão "Reenviar e-mail"
              TextButton(
                onPressed: _loadingReenviar ? null : _reenviarEmail,
                child: _loadingReenviar
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Reenviar e-mail de verificação',
                        style: TextStyle(
                          color: Color(0xFFFFC107),
                          fontWeight: FontWeight.bold,
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
