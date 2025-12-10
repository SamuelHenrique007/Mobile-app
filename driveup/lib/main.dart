import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// telas
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
import 'screens/perfil_page.dart';

// navegação global
import 'navigation/main_navigation.dart';

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

      // 👉 Começa pela Splash (ela decide se vai pro login ou pra MainNavigation)
      home: const SplashScreen(),

      routes: {
        '/menu': (context) => const MenuDevPage(),
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
        // rota opcional se quiser chamar MainNavigation por nome
        '/main': (context) => const MainNavigation(),
        '/perfil': (context) => const PerfilPage(),
      },
    );
  }
}
