import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:driveup/services/auth_service.dart'; // ajuste o import se o nome do pacote for outro

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmaSenhaController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  final _authService = AuthService();

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final user = await _authService.register(
        name: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        password: _senhaController.text.trim(),
      );

      if (user != null) {
        _showSnack('Cadastro realizado! Verifique seu e-mail.');
        // Vai para tela de confirmação
        Navigator.pushNamed(context, '/cadastroConfirm');
      }
    } on FirebaseAuthException catch (e) {
      _showSnack(e.message ?? 'Erro ao cadastrar');
    } catch (e) {
      _showSnack('Erro inesperado: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmaSenhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          width: 350,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Logo
                  Image.asset('assets/images/driveup_logo.png', height: 120),
                  const SizedBox(height: 10),
                  const Text(
                    'DriveUP',
                    style: TextStyle(
                      color: Color(0xFFFFC107),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // NOME
                  _campoDecorado(
                    iconPath: 'assets/icons/email.png',
                    hint: 'Digite seu nome',
                    controller: _nomeController,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Informe seu nome' : null,
                  ),
                  const SizedBox(height: 15),

                  // EMAIL
                  _campoDecorado(
                    iconPath: 'assets/icons/email.png',
                    hint: 'Digite seu email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Informe seu e-mail';
                      if (!v.contains('@')) return 'E-mail inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),

                  // SENHA
                  _campoDecorado(
                    iconPath: 'assets/icons/senha.png',
                    hint: 'Digite sua senha',
                    controller: _senhaController,
                    obscure: true,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Informe a senha';
                      if (v.length < 6) return 'Mínimo 6 caracteres';
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),

                  // CONFIRMA SENHA
                  _campoDecorado(
                    iconPath: 'assets/icons/senha.png',
                    hint: 'Digite novamente sua senha',
                    controller: _confirmaSenhaController,
                    obscure: true,
                    validator: (v) {
                      if (v != _senhaController.text) {
                        return 'As senhas não coincidem';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  const Divider(height: 30, thickness: 0.5),
                  const Text(
                    'ou use também',
                    style: TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/icons/google.png', height: 30),
                      const SizedBox(width: 20),
                      Image.asset('assets/icons/facebook.png', height: 30),
                      const SizedBox(width: 20),
                      Image.asset('assets/icons/apple.png', height: 30),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Botão continuar
                  ElevatedButton(
                    onPressed: _loading ? null : _cadastrar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC107),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 100,
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'CONTINUAR',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _campoDecorado({
    required String iconPath,
    required String hint,
    required TextEditingController controller,
    bool obscure = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          children: [
            Image.asset(
              iconPath,
              width: 20,
              height: 20,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: controller,
                obscureText: obscure,
                keyboardType: keyboardType,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                validator: validator,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
