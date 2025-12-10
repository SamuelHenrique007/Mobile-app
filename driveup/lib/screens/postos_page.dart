import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:driveup/services/fuel_service.dart';

class FuelStationsPage extends StatelessWidget {
  const FuelStationsPage({super.key});

  static const yellow = Color(0xFFFFC107);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: .5,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          'Postos de Combustíveis',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FuelService.instance.fuelsByUserStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar abastecimentos: ${snapshot.error}'),
            );
          }

          final fuels = snapshot.data ?? [];

          // Agrupar por posto
          final Map<String, _StationSummary> stations = {};

          for (final m in fuels) {
            final rawName = (m['station'] as String?)?.trim();
            if (rawName == null || rawName.isEmpty) continue;

            final name = rawName;
            final ts = m['dateTime'] as Timestamp?;
            final dt = ts?.toDate();
            final totalPrice = (m['totalPrice'] as num?)?.toDouble() ?? 0.0;

            final summary = stations[name] ?? _StationSummary(name: name);
            summary.count += 1;
            summary.totalSpent += totalPrice;

            if (dt != null) {
              if (summary.lastDate == null ||
                  dt.isAfter(summary.lastDate!)) {
                summary.lastDate = dt;
              }
            }

            stations[name] = summary;
          }

          if (stations.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum posto cadastrado ainda.\n'
                'Registre abastecimentos informando o campo "Posto" para ver os resultados aqui.',
                textAlign: TextAlign.center,
              ),
            );
          }

          final list = stations.values.toList()
            ..sort((a, b) {
              final da = a.lastDate?.millisecondsSinceEpoch ?? 0;
              final db = b.lastDate?.millisecondsSinceEpoch ?? 0;
              return db.compareTo(da); // último abastecimento primeiro
            });

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final s = list[index];

              final lastDateStr = s.lastDate == null
                  ? 'Sem data registrada'
                  : '${s.lastDate!.day.toString().padLeft(2, '0')}/'
                    '${s.lastDate!.month.toString().padLeft(2, '0')}/'
                    '${s.lastDate!.year}';

              return Card(
                elevation: 1.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.local_gas_station,
                    color: yellow,
                  ),
                  title: Text(
                    s.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Text(
                        '${s.count} abastecimento${s.count > 1 ? 's' : ''}',
                      ),
                      Text('Último abastecimento: $lastDateStr'),
                    ],
                  ),
                  trailing: Text(
                    'R\$ ${s.totalSpent.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  // Se quiser futuramente, podemos abrir detalhes
                  onTap: () {
                    // TODO: tela com histórico filtrado por esse posto
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

class _StationSummary {
  final String name;
  int count;
  double totalSpent;
  DateTime? lastDate;

  _StationSummary({
    required this.name,
    this.count = 0,
    this.totalSpent = 0.0,
    this.lastDate,
  });
}
