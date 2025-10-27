import 'package:flutter/material.dart';

class CadastroConfirmPage extends StatelessWidget {
  const CadastroConfirmPage({super.key});

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
              // Logo
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

              // Texto de instrução
              const Text(
                'Confirme seu e-mail para ativar sua conta',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.black87),
              ),
              const SizedBox(height: 25),

              // Campo de código
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F4F4),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Code - 77777',
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Image.asset(
                        'assets/icons/email.png', // <- Ícone do código
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

              // Botão CONTINUAR
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC107),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'CONTINUAR',
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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
