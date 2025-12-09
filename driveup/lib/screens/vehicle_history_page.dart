import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'package:driveup/services/vehicle_service.dart';
import 'package:driveup/services/expense_service.dart';
import 'package:driveup/services/fuel_service.dart';

class VehicleHistoryPage extends StatelessWidget {
  final Vehicle vehicle;

  const VehicleHistoryPage({super.key, required this.vehicle});

  String _formatDate(dynamic value) {
    if (value is Timestamp) {
      final dt = value.toDate();
      return DateFormat('dd/MM/yyyy HH:mm').format(dt);
    }
    if (value is DateTime) {
      return DateFormat('dd/MM/yyyy HH:mm').format(value);
    }
    return '-';
  }

  String _formatMoney(dynamic value) {
    if (value == null) return '-';
    if (value is num) {
      return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
    }
    return '-';
  }

  String _formatLiters(dynamic value) {
    if (value == null) return '-';
    if (value is num) {
      return '${value.toStringAsFixed(2).replaceAll('.', ',')} L';
    }
    return '-';
  }

  @override
  Widget build(BuildContext context) {
    const yellow = Color(0xFFFFC107);
    final isMoto = vehicle.type == 'Moto';
    final icon = isMoto
        ? Icons.motorcycle_outlined
        : Icons.directions_car_outlined;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: .5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'HISTÓRICO',
          style: TextStyle(
            color: Colors.black87,
            letterSpacing: 1,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: yellow,
              child: Icon(Icons.person, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Card do veículo
          Card(
            color: const Color(0xFFFFF3E0),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 40, color: Colors.black87),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vehicle.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 16,
                          runSpacing: 4,
                          children: [
                            _TagChip('Modelo', vehicle.model),
                            _TagChip('Ano', vehicle.year),
                            _TagChip('Marca', vehicle.brand),
                            _TagChip('Cor', vehicle.color),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          const _SectionHeader('ABASTECIMENTOS'),
          const SizedBox(height: 8),

          StreamBuilder<List<Map<String, dynamic>>>(
            stream: FuelService.instance.fuelsByVehicleStream(vehicle.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: LinearProgressIndicator(minHeight: 2),
                );
              }

              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    'Erro ao carregar abastecimentos: ${snapshot.error}',
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                );
              }

              final items = snapshot.data ?? [];
              if (items.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    'Nenhum abastecimento registrado para este veículo.',
                    style: TextStyle(color: Colors.black54),
                  ),
                );
              }

              return Column(
                children: items.map((fuel) {
                  final dateTime = fuel['dateTime'];
                  final total = fuel['totalPrice'];
                  final liters = fuel['liters'];
                  final station = fuel['station'] ?? '-';
                  final fuelType = fuel['fuelType'] ?? '-';

                  return Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(0xFFFFD600),
                        child: Icon(
                          Icons.local_gas_station_outlined,
                          color: Colors.black87,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        '${_formatMoney(total)} • ${_formatLiters(liters)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '${_formatDate(dateTime)}\nPosto: $station\nTipo: $fuelType',
                        style: const TextStyle(fontSize: 12.5),
                      ),
                      isThreeLine: true,
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 16),
          const _SectionHeader('DESPESAS'),
          const SizedBox(height: 8),

          StreamBuilder<List<Map<String, dynamic>>>(
            stream: ExpenseService.instance.expensesByVehicleStream(vehicle.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: LinearProgressIndicator(minHeight: 2),
                );
              }

              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    'Erro ao carregar despesas: ${snapshot.error}',
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                );
              }

              final items = snapshot.data ?? [];
              if (items.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    'Nenhuma despesa registrada para este veículo.',
                    style: TextStyle(color: Colors.black54),
                  ),
                );
              }

              return Column(
                children: items.map((exp) {
                  final type = exp['expenseType'] ?? '-';
                  final value = exp['value'];
                  final local = exp['local'] ?? '-';
                  final dateTime = exp['dateTime'];

                  return Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(0xFFFF5252),
                        child: Icon(
                          Icons.receipt_long_outlined,
                          color: Colors.black87,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        '$type • ${_formatMoney(value)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '${_formatDate(dateTime)}\nLocal: $local',
                        style: const TextStyle(fontSize: 12.5),
                      ),
                      isThreeLine: true,
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: .8,
          color: Colors.black87,
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final String value;
  const _TagChip(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: Colors.grey.shade200,
      label: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 11.5, color: Colors.black87),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6),
    );
  }
}
