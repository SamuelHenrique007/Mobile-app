import 'package:flutter/material.dart';

class SobrePage extends StatelessWidget {
  const SobrePage({super.key});

  static const yellow = Color(0xFFFFC107);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: .5,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          'Sobre o DriveUP',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SizedBox(height: 8),

          // Ícone / “logo”
          Center(
            child: Image.asset(
              'assets/images/driveup_logo.png',
              width: 72,   // equivalente ao radius 36
              height: 72,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: 12),

          Center(
            child: Text(
              'DriveUP',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
          SizedBox(height: 4),

          Center(
            child: Text(
              'v1.0.0 · Protótipo acadêmico',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ),

          SizedBox(height: 24),

          Text(
            'O que é o DriveUP?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'O DriveUP é um sistema voltado para o controle de veículos pessoais ou '
            'da frota de pequenas empresas. A proposta é facilitar o registro e o '
            'acompanhamento do uso dos veículos de forma simples, visual e acessível '
            'a partir do celular.',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),

          SizedBox(height: 16),

          Text(
            'Principais funcionalidades',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '• Cadastro de veículos, com informações básicas para identificação.\n'
            '• Registro de abastecimentos, incluindo data, hodômetro, tipo de combustível, '
            'valor total, valor por litro, litros e posto.\n'
            '• Registro de despesas diversas do veículo (manutenção, impostos, seguros etc.).\n'
            '• Histórico detalhado por veículo, permitindo acompanhar a evolução de custos.\n'
            '• Visão geral dos gastos na tela inicial, com gráficos e resumos mensais.\n'
            '• Integração com autenticação de usuário, permitindo que cada pessoa tenha '
            'seus próprios dados e veículos.',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),

          SizedBox(height: 16),

          Text(
            'Objetivo do sistema',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'O objetivo do DriveUP é apoiar o motorista na organização financeira e na '
            'manutenção dos veículos, tornando mais fácil visualizar onde o dinheiro '
            'está sendo gasto e quando algum tipo de intervenção é necessária '
            '(como revisões, trocas de óleo ou pneus).',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),

          SizedBox(height: 16),

          Text(
            'Tecnologias utilizadas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87),
          ),
          SizedBox(height: 8),
          Text(
            'O aplicativo foi desenvolvido em Flutter, utilizando integração com serviços '
            'em nuvem (como Firebase/Firestore) para autenticação e armazenamento dos dados. '
            'Isso permite que os registros de abastecimentos, despesas e veículos fiquem '
            'sincronizados e disponíveis em diferentes dispositivos.',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),

          SizedBox(height: 24),

          Text(
            'Aviso',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Esta versão do DriveUP é um protótipo acadêmico em constante evolução. '
            'Algumas funcionalidades podem ser ajustadas, removidas ou adicionadas ao '
            'longo do desenvolvimento.',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),

          SizedBox(height: 24),
        ],
      ),
    );
  }
}
