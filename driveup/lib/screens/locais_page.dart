import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:driveup/services/expense_service.dart';

class ExpenseLocationsPage extends StatelessWidget {
  const ExpenseLocationsPage({super.key});

  static const yellow = Color(0xFFFFC107);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: .5,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          'Locais de Despesa',
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

          final expenses = snapshot.data ?? [];

          // Agrupar por local
          final Map<String, _LocationSummary> locations = {};

          for (final m in expenses) {
            final rawLocal = (m['local'] as String?)?.trim();
            if (rawLocal == null || rawLocal.isEmpty) continue;

            final ts = m['dateTime'] as Timestamp?;
            final dt = ts?.toDate();

            final value = (m['value'] as num?)?.toDouble() ?? 0.0;

            final loc = locations[rawLocal] ?? _LocationSummary(name: rawLocal);
            loc.count += 1;
            loc.totalSpent += value;

            if (dt != null) {
              if (loc.lastDate == null || dt.isAfter(loc.lastDate!)) {
                loc.lastDate = dt;
              }
            }

            locations[rawLocal] = loc;
          }

          if (locations.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum local encontrado.\n'
                'Registre despesas informando o campo "Local" para aparecer aqui.',
                textAlign: TextAlign.center,
              ),
            );
          }

          final list = locations.values.toList()
            ..sort((a, b) {
              final da = a.lastDate?.millisecondsSinceEpoch ?? 0;
              final db = b.lastDate?.millisecondsSinceEpoch ?? 0;
              return db.compareTo(da); // último gasto primeiro
            });

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final loc = list[index];

              final lastDateStr = loc.lastDate == null
                  ? 'Sem data registrada'
                  : '${loc.lastDate!.day.toString().padLeft(2, '0')}/'
                    '${loc.lastDate!.month.toString().padLeft(2, '0')}/'
                    '${loc.lastDate!.year}';

              return Card(
                elevation: 1.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.location_on_outlined,
                    color: yellow,
                  ),
                  title: Text(
                    loc.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${loc.count} despesa${loc.count > 1 ? 's' : ''}'),
                      Text('Último gasto: $lastDateStr'),
                    ],
                  ),
                  trailing: Text(
                    'R\$ ${loc.totalSpent.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  onTap: () {
                    // TODO: Detalhes do local → histórico filtrado
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

class _LocationSummary {
  final String name;
  int count;
  double totalSpent;
  DateTime? lastDate;

  _LocationSummary({
    required this.name,
    this.count = 0,
    this.totalSpent = 0.0,
    this.lastDate,
  });
}
