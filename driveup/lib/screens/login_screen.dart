import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1C), // Fundo externo escuro
      body: Center(
        child: Container(
          width: 340,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // LOGO
                Image.asset('assets/images/driveup_logo.png', width: 120),
                const SizedBox(height: 10),
                const Text(
                  "DriveUP",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFC107),
                  ),
                ),
                const SizedBox(height: 30),

                // CAMPO EMAIL
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/icons/email.png',
                          width: 20,
                          height: 20,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'Digite seu email',
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // CAMPO SENHA
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/icons/senha.png',
                          width: 20,
                          height: 20,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            obscureText: true,
                            decoration: const InputDecoration(
                              hintText: 'Digite sua senha',
                              hintStyle: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Esqueceu a senha
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                    ),
                    child: const Text(
                      "Esqueceu a senha?",
                      style: TextStyle(color: Color(0xFFFFC107), fontSize: 13),
                    ),
                  ),
                ),

                const Divider(height: 30),
                const Text("ou use também"),
                const SizedBox(height: 10),

                // LOGIN SOCIAL
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Image.asset(
                        'assets/icons/google.png',
                        width: 35,
                        height: 35,
                      ),
                    ),
                    const SizedBox(width: 25),
                    GestureDetector(
                      onTap: () {},
                      child: Image.asset(
                        'assets/icons/facebook.png',
                        width: 35,
                        height: 35,
                      ),
                    ),
                    const SizedBox(width: 25),
                    GestureDetector(
                      onTap: () {},
                      child: Image.asset(
                        'assets/icons/apple.png',
                        width: 35,
                        height: 35,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // BOTÃO CONTINUAR
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC107),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {},
                    child: const Text(
                      "CONTINUAR",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // CADASTRO
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Não tem uma conta? ",
                      style: TextStyle(color: Colors.black87),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        "Cadastre-se",
                        style: TextStyle(
                          color: Color(0xFFFFC107),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
