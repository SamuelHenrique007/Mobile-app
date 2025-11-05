import 'package:flutter/material.dart';

class MenuDevPage extends StatelessWidget {
  const MenuDevPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> telas = [
      {'nome': 'Splash', 'rota': '/splash'},
      {'nome': 'Login', 'rota': '/login'},
      {'nome': 'Cadastro', 'rota': '/cadastro'},
      {'nome': 'Confirmação de Cadastro', 'rota': '/cadastroConfirm'},
      {'nome': 'Home', 'rota': '/home'},
      {'nome': 'Notificações', 'rota': '/notificacoes'},
      {'nome': 'Sem Notificações', 'rota': '/emptyNotifications'},
      {'nome': 'Mensagem Notificação', 'rota': '/mensagemNotificacao'},
      {'nome': 'Veículos', 'rota': '/veiculos'},
      {'nome': 'Formulário Veículo', 'rota': '/formVeiculo'},
      {'nome': 'Relatório', 'rota': '/relatorio'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu de Telas (Dev)'),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: telas.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final tela = telas[index];
          return ListTile(
            leading: const Icon(Icons.arrow_forward_ios, size: 18),
            title: Text(
              tela['nome']!,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            trailing: const Icon(Icons.play_arrow, color: Colors.amber),
            onTap: () => Navigator.pushNamed(context, tela['rota']!),
          );
        },
      ),
    );
  }
}
