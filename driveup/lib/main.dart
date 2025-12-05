import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

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

  // Inicializa o Firebase (usa o arquivo gerado pelo flutterfire)
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
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      ),

      // Para desenvolvimento você pode começar pelo menu
      // depois, se quiser, troca para '/splash' ou '/login'
      initialRoute: '/menu',

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

      // fallback se chamar uma rota errada
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Rota não encontrada'))),
        );
      },
    );
  }
}
