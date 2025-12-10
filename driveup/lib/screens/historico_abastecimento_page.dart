import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:driveup/services/fuel_service.dart';
import 'package:driveup/services/vehicle_service.dart';

class FuelHistoryPage extends StatelessWidget {
  const FuelHistoryPage({super.key});

  static const yellow = Color(0xFFFFC107);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Abastecimentos',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: .5,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),

      // 1º Stream: veículos (para mapear id -> nome)
      body: StreamBuilder<List<Vehicle>>(
        stream: VehicleService.instance.vehiclesStream(),
        builder: (context, vehiclesSnap) {
          if (vehiclesSnap.connectionState == ConnectionState.waiting &&
              !vehiclesSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (vehiclesSnap.hasError) {
            return Center(
              child: Text('Erro ao carregar veículos: ${vehiclesSnap.error}'),
            );
          }

          final vehicles = vehiclesSnap.data ?? [];

          // Mapa de id -> nome pra lookup rápido
          final Map<String, String> vehicleNameById = {
            for (final v in vehicles) v.id: v.name,
          };

          // 2º Stream: abastecimentos do usuário
          return StreamBuilder<List<Map<String, dynamic>>>(
            stream: FuelService.instance.fuelsByUserStream(),
            builder: (context, fuelsSnap) {
              if (fuelsSnap.connectionState == ConnectionState.waiting &&
                  !fuelsSnap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              if (fuelsSnap.hasError) {
                return Center(
                  child: Text(
                    'Erro ao carregar abastecimentos: ${fuelsSnap.error}',
                  ),
                );
              }

              final items = fuelsSnap.data ?? [];

              if (items.isEmpty) {
                return const Center(
                  child: Text('Nenhum abastecimento registrado ainda.'),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final m = items[index];

                  final ts = m['dateTime'] as Timestamp?;
                  final dt = ts?.toDate();
                  final dateStr = dt == null
                      ? 'Data não informada'
                      : '${dt.day.toString().padLeft(2, '0')}/'
                        '${dt.month.toString().padLeft(2, '0')}/'
                        '${dt.year}';

                  final odometer = (m['odometer'] as num?)?.toDouble();
                  final liters = (m['liters'] as num?)?.toDouble();
                  final total = (m['totalPrice'] as num?)?.toDouble();
                  final fuelType = m['fuelType'] as String?;
                  final station = m['station'] as String?;

                  final vehicleId = (m['vehicleId'] as String?)?.trim();
                  final vehicleNameFromDoc =
                      (m['vehicleName'] as String?)?.trim();

                  // 1) Se o doc já tiver vehicleName, usa ele
                  // 2) Senão, tenta achar pelo map id -> nome
                  // 3) Senão, mostra o próprio id
                  String vehicleLabel = 'não informado';
                  if (vehicleNameFromDoc != null &&
                      vehicleNameFromDoc.isNotEmpty) {
                    vehicleLabel = vehicleNameFromDoc;
                  } else if (vehicleId != null && vehicleId.isNotEmpty) {
                    vehicleLabel =
                        vehicleNameById[vehicleId] ?? vehicleId;
                  }

                  final fuelTypeStr = (fuelType != null && fuelType.isNotEmpty)
                      ? fuelType
                      : '—';

                  final stationStr = (station != null && station.isNotEmpty)
                      ? station
                      : '—';

                  return Card(
                    elevation: 1.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: yellow,
                        child: Icon(
                          Icons.local_gas_station,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        'Veículo: $vehicleLabel',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 2),
                          Text('Data: $dateStr'),
                          Text('Combustível: $fuelTypeStr'),
                          Text('Posto: $stationStr'),
                          if (odometer != null)
                            Text('Odômetro: ${odometer.toStringAsFixed(0)} km'),
                          if (liters != null)
                            Text('Litros: ${liters.toStringAsFixed(2)} L'),
                        ],
                      ),
                      trailing: total == null
                          ? const SizedBox.shrink()
                          : Text(
                              'R\$ ${total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                      onTap: () {
                        // depois podemos abrir detalhes / edição
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
