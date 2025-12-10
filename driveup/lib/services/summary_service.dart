import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MonthlySummary {
  final double fuelTotal;    // total gasto com abastecimento no mês
  final double expenseTotal; // total gasto com despesas no mês
  final double kmTotal;      // km totais (no mês, a partir do odômetro dos fuels)
  final double kmDailyAvg;   // média diária de km no mês

  MonthlySummary({
    required this.fuelTotal,
    required this.expenseTotal,
    required this.kmTotal,
    required this.kmDailyAvg,
  });

  factory MonthlySummary.empty() => MonthlySummary(
        fuelTotal: 0,
        expenseTotal: 0,
        kmTotal: 0,
        kmDailyAvg: 0,
      );
}

class SummaryService {
  SummaryService._();
  static final SummaryService instance = SummaryService._();

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;

  /// Resumo mensal (fuels + expenses), filtrando por user
  /// e aplicando o filtro de data no cliente.
  ///
  /// Também calcula:
  /// - kmTotal: diferença entre menor e maior odômetro de cada veículo no mês
  /// - kmDailyAvg: kmTotal / dias do mês
  Stream<MonthlySummary> summaryForMonth({
    required int year,
    required int month,
  }) {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value(MonthlySummary.empty());
    }

    final start = DateTime(year, month, 1);
    final end = (month == 12)
        ? DateTime(year + 1, 1, 1)
        : DateTime(year, month + 1, 1);

    // número de dias do mês (sem depender de Flutter/DateUtils)
    final daysInMonth = DateTime(year, month + 1, 0).day.toDouble();

    // ---------- Abastecimentos ----------
    final fuelsStream = _firestore
        .collection('fuels')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snap) {
      // filtra docs do mês
      final filteredDocs = snap.docs.where((doc) {
        final data = doc.data();
        final ts = data['dateTime'] as Timestamp?;
        final dt = ts?.toDate();
        return dt != null && dt.isAfterOrAt(start) && dt.isBefore(end);
      }).toList();

      final fuelMaps = filteredDocs.map((d) => d.data()).toList();

      // total de combustível (totalPrice)
      double fuelTotal = 0;
      for (final data in fuelMaps) {
        fuelTotal += (data['totalPrice'] as num?)?.toDouble() ?? 0.0;
      }

      // km totais a partir do odômetro (por veículo)
      final kmTotal = _computeKmFromFuels(fuelMaps);

      // média diária de km
      final kmDailyAvg =
          (daysInMonth > 0 && kmTotal > 0) ? kmTotal / daysInMonth : 0.0;

      return _FuelAgg(
        fuelTotal: fuelTotal,
        kmTotal: kmTotal,
        kmDailyAvg: kmDailyAvg,
      );
    });

    // ---------- Despesas ----------
    final expenseStream = _firestore
        .collection('expenses')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snap) {
      double total = 0;
      for (final doc in snap.docs) {
        final data = doc.data();
        final ts = data['dateTime'] as Timestamp?;
        final dt = ts?.toDate();
        if (dt != null && dt.isAfterOrAt(start) && dt.isBefore(end)) {
          total += (data['value'] as num?)?.toDouble() ?? 0;
        }
      }
      return total;
    });

    // ---------- Combina tudo em um MonthlySummary ----------
    return fuelsStream.asyncCombine(
      expenseStream,
      (fuelAgg, expenseTotal) {
        return MonthlySummary(
          fuelTotal: fuelAgg.fuelTotal,
          expenseTotal: expenseTotal,
          kmTotal: fuelAgg.kmTotal,
          kmDailyAvg: fuelAgg.kmDailyAvg,
        );
      },
    );
  }

  /// Calcula km a partir da lista de abastecimentos do mês.
  /// Agrupa por veículo, pega o menor e o maior odômetro de cada um
  /// e soma (last - first) quando for positivo.
  static double _computeKmFromFuels(List<Map<String, dynamic>> fuels) {
    if (fuels.isEmpty) return 0;

    final Map<String, List<Map<String, dynamic>>> byVehicle = {};

    for (final m in fuels) {
      final vid = (m['vehicleId'] as String?) ?? 'sem-vehicle';
      byVehicle.putIfAbsent(vid, () => []).add(m);
    }

    double totalKm = 0;

    byVehicle.forEach((vid, list) {
      // pega apenas odômetros válidos (> 0)
      final odos = list
          .map((e) => e['odometer'])
          .where((v) => v is num && v > 0)
          .map((v) => (v as num).toDouble())
          .toList();

      if (odos.length < 2) return;

      odos.sort();
      final first = odos.first;
      final last = odos.last;
      final diff = last - first;

      if (diff > 0) {
        totalKm += diff;
      }
    });

    return totalKm;
  }
}

/// Struct interna pra combinar fuel + km na stream
class _FuelAgg {
  final double fuelTotal;
  final double kmTotal;
  final double kmDailyAvg;

  _FuelAgg({
    required this.fuelTotal,
    required this.kmTotal,
    required this.kmDailyAvg,
  });
}

/// Helpers de datas
extension on DateTime {
  bool isAfterOrAt(DateTime other) =>
      isAfter(other) || isAtSameMomentAs(other);
}

/// Extensão para combinar duas streams em tempo real
extension CombineTwo<A> on Stream<A> {
  Stream<R> asyncCombine<B, R>(
    Stream<B> other,
    R Function(A a, B b) combiner,
  ) {
    late A lastA;
    late B lastB;

    bool hasA = false;
    bool hasB = false;

    final controller = StreamController<R>();

    final subA = listen((a) {
      lastA = a;
      hasA = true;
      if (hasB) controller.add(combiner(lastA, lastB));
    });

    final subB = other.listen((b) {
      lastB = b;
      hasB = true;
      if (hasA) controller.add(combiner(lastA, lastB));
    });

    controller.onCancel = () {
      subA.cancel();
      subB.cancel();
    };

    return controller.stream;
  }
}
