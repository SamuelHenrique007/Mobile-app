import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:driveup/services/expense_service.dart';

class ExpenseHistoryPage extends StatelessWidget {
  const ExpenseHistoryPage({super.key});

  static const yellow = Color(0xFFFFC107);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: .5,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          'Histórico de Despesas',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: ExpenseService.instance.expensesByUserStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar despesas: ${snapshot.error}'),
            );
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma despesa registrada ainda.',
                style: TextStyle(color: Colors.black87),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final m = items[index];

              // data
              final ts = m['dateTime'] as Timestamp?;
              final dt = ts?.toDate();
              final dateStr = dt == null
                  ? 'Data não informada'
                  : '${dt.day.toString().padLeft(2, '0')}/'
                    '${dt.month.toString().padLeft(2, '0')}/'
                    '${dt.year}';

              // veículo
              final vehicleName = (m['vehicleName'] as String?)?.trim();
              final vehicleId = (m['vehicleId'] as String?)?.trim();
              String vehicleLabel = 'Veículo não informado';
              if (vehicleName != null && vehicleName.isNotEmpty) {
              vehicleLabel = vehicleName;
              } else if (vehicleId != null && vehicleId.isNotEmpty) {
              vehicleLabel = vehicleId;
              }


              // demais campos
              final expenseType = (m['expenseType'] as String?) ?? 'Despesa';
              final local = (m['local'] as String?) ?? '—';
              final paymentMethod = (m['paymentMethod'] as String?) ?? '—';
              final driver = (m['driver'] as String?) ?? 'Não informado';
              final value = (m['value'] as num?)?.toDouble();
              final odometer = (m['odometer'] as num?)?.toDouble();

              return Card(
                elevation: 1.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    radius: 20,
                    backgroundColor: yellow,
                    child: Icon(
                      Icons.receipt_long,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    expenseType,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Text('Veículo: $vehicleLabel'),
                      Text('Local: $local'),
                      Text('Data: $dateStr'),
                      if (odometer != null)
                        Text('Odômetro: ${odometer.toStringAsFixed(0)} km'),
                      Text('Motorista: $driver'),
                      Text('Pagamento: $paymentMethod'),
                    ],
                  ),
                  trailing: value == null
                      ? const SizedBox.shrink()
                      : Text(
                          'R\$ ${value.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                  // se quiser depois: editar ao tocar
                  onTap: () {
                    // TODO: abrir tela de edição de despesa, se desejar
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
