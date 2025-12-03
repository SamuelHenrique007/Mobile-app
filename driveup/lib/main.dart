import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';

// Telas
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/cadastro_page.dart';
import 'screens/home_screen.dart';
import 'screens/cadastro_confirm_page.dart';
import 'screens/notificacoes_page.dart';
import 'screens/empty_notifications_page.dart';
import 'screens/mensagem_notificacao_page.dart';
import 'screens/veiculos_page.dart';
import 'screens/form_veiculo_page.dart';
import 'screens/relatorios_page.dart';
import 'screens/menu_dev_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DriveUp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
      ),

      // Em vez de initialRoute, usamos um “portão” que decide a tela inicial
      home: const AuthGate(),

      routes: {
        '/menu': (context) => const MenuDevPage(),
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/cadastro': (context) => const CadastroPage(),
        '/cadastroConfirm': (context) => const CadastroConfirmPage(),
        '/home': (context) => const HomePage(),
        '/notificacoes': (context) => const NotificacoesPage(),
        '/emptyNotifications': (context) => const EmptyNotificationsPage(),
        '/mensagemNotificacao': (context) => const MensagemNotificacaoPage(),
        '/veiculos': (context) => const VeiculosPage(),
        '/formVeiculo': (context) => const FormVeiculoPage(),
        '/relatorio': (context) => const RelatoriosPage(),
      },
    );
  }
}

/// Decide automaticamente se mostra Login, Confirmação ou Home
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Enquanto o Firebase está carregando o usuário
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        final user = snapshot.data;

        // Ninguém logado -> vai para Login
        if (user == null) {
          return const LoginScreen();
        }

        // Logado mas sem e-mail verificado -> tela de confirmação
        if (!user.emailVerified) {
          return const CadastroConfirmPage();
        }

        // Logado e verificado -> Home
        return const HomePage();
      },
    );
  }
}
