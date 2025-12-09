import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MonthlySummary {
  final double fuelTotal;
  final double expenseTotal;

  MonthlySummary({
    required this.fuelTotal,
    required this.expenseTotal,
  });
}

class SummaryService {
  SummaryService._();
  static final SummaryService instance = SummaryService._();

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;

  /// Resumo mensal (fuels + expenses), filtrando por user
  /// e aplicando o filtro de data no cliente.
  Stream<MonthlySummary> summaryForMonth({
    required int year,
    required int month,
  }) {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value(
        MonthlySummary(fuelTotal: 0, expenseTotal: 0),
      );
    }

    final start = DateTime(year, month, 1);
    final end = (month == 12)
        ? DateTime(year + 1, 1, 1)
        : DateTime(year, month + 1, 1);

    // 🔹 Abastecimentos do usuário (filtro de data só no cliente)
    final fuelsStream = _firestore
        .collection('fuels')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snap) {
      double total = 0;
      for (final doc in snap.docs) {
        final data = doc.data();
        final ts = data['dateTime'] as Timestamp?;
        final dt = ts?.toDate();
        if (dt != null && dt.isAfterOrAt(start) && dt.isBefore(end)) {
          total += (data['totalPrice'] as num?)?.toDouble() ?? 0;
        }
      }
      return total;
    });

    // 🔹 Despesas do usuário (filtro de data só no cliente)
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

    return fuelsStream.asyncCombine(expenseStream, (double fuel, double exp) {
      return MonthlySummary(
        fuelTotal: fuel,
        expenseTotal: exp,
      );
    });
  }
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
