import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Representa uma despesa com id + dados do documento.
class ExpenseRecord {
  final String id;
  final Map<String, dynamic> data;

  ExpenseRecord({required this.id, required this.data});
}

class ExpenseService {
  ExpenseService._();
  static final ExpenseService instance = ExpenseService._();

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// Converte número BR "1.234,56" -> 1234.56
  double? parseBrDouble(String? value) {
    if (value == null) return null;
    final txt = value.trim();
    if (txt.isEmpty) return null;

    final normalized = txt.replaceAll('.', '').replaceAll(',', '.');

    return double.tryParse(normalized);
  }

  Future<void> createExpense({
    required String vehicleId,
    required DateTime dateTime,
    required String expenseType,
    required String local,
    required String paymentMethod,
    String? observation,
    double? odometer,
    double? value,
    String driver = 'Não informado',
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado.');
    }

    final now = DateTime.now();

    final data = <String, dynamic>{
      'userId': user.uid,
      'vehicleId': vehicleId,
      'dateTime': Timestamp.fromDate(dateTime),
      'expenseType': expenseType,
      'local': local,
      'driver': driver,
      'paymentMethod': paymentMethod,
      'observation': observation,
      'odometer': odometer,
      'value': value,
      'createdAt': Timestamp.fromDate(now),
    };

    await _firestore.collection('expenses').add(data);
  }

  Future<void> updateExpense({
    required String id,
    required String vehicleId,
    required DateTime dateTime,
    required String expenseType,
    required String local,
    required String paymentMethod,
    String? observation,
    double? odometer,
    double? value,
    String driver = 'Não informado',
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado.');
    }

    final data = <String, dynamic>{
      'userId': user.uid,
      'vehicleId': vehicleId,
      'dateTime': Timestamp.fromDate(dateTime),
      'expenseType': expenseType,
      'local': local,
      'driver': driver,
      'paymentMethod': paymentMethod,
      'observation': observation,
      'odometer': odometer,
      'value': value,
    };

    await _firestore.collection('expenses').doc(id).update(data);
  }

  Future<void> deleteExpense(String id) async {
    await _firestore.collection('expenses').doc(id).delete();
  }

  /// Stream de despesas por veículo, com id e ordenadas (mais recentes primeiro)
  Stream<List<ExpenseRecord>> expensesByVehicleStream(String vehicleId) {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream<List<ExpenseRecord>>.empty();
    }

    return _firestore
        .collection('expenses')
        .where('userId', isEqualTo: user.uid)
        .where('vehicleId', isEqualTo: vehicleId)
        // sem orderBy pra não exigir índice composto
        .snapshots()
        .map((snap) {
          final docs = snap.docs
              .map((d) => ExpenseRecord(id: d.id, data: d.data()))
              .toList();

          docs.sort((a, b) {
            final ta = a.data['dateTime'] as Timestamp?;
            final tb = b.data['dateTime'] as Timestamp?;
            final ma = ta?.millisecondsSinceEpoch ?? 0;
            final mb = tb?.millisecondsSinceEpoch ?? 0;
            return mb.compareTo(ma); // desc
          });

          return docs;
        });
  }
}
