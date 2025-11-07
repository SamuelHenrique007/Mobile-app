import 'package:flutter/material.dart';


// Importar todas as telas
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
import 'screens/menu_dev_page.dart'; // (vamos criar já já)
import 'screens/perfil_page.dart';
import 'screens/sidemenu_page.dart';

void main() => runApp(const MyApp());

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

      // A tela inicial será o MENU DE DESENVOLVIMENTO
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
        '/perfil': (context) => const PerfilPage(),
        '/sidemenu': (context) => const SideMenuPage(),
      },
    );
  }
}
