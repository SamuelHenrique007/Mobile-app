import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ExpenseService {
  ExpenseService._();
  static final ExpenseService instance = ExpenseService._();

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// Converte string com vírgula para double (padrão brasileiro).
  /// Ex.: "1.234,56" -> 1234.56
  double? parseBrDouble(String? value) {
    if (value == null) return null;
    final txt = value.trim();
    if (txt.isEmpty) return null;

    final normalized = txt
        .replaceAll('.', '') // remove separador de milhar
        .replaceAll(',', '.'); // troca vírgula por ponto

    return double.tryParse(normalized);
  }

  Future<void> createExpense({
    required String vehicleId,
    required DateTime dateTime,
    required String expenseType,
    required String local,
    required String driver,
    required String paymentMethod,
    String? observation,
    double? odometer,
    double? value, // valor da despesa
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

  /// Stream de despesas filtradas por veículo
  Stream<List<Map<String, dynamic>>> expensesByVehicleStream(String vehicleId) {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream<List<Map<String, dynamic>>>.empty();
    }

    return _firestore
        .collection('expenses')
        .where('userId', isEqualTo: user.uid)
        .where('vehicleId', isEqualTo: vehicleId)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList());
  }
}
