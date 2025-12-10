import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Representa um abastecimento com id + dados do documento.
class FuelRecord {
  final String id;
  final Map<String, dynamic> data;

  FuelRecord({required this.id, required this.data});
}

class FuelService {
  FuelService._();
  static final FuelService instance = FuelService._();

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> createFuel({
    required String vehicleId,
    required String vehicleName,
    required DateTime dateTime,
    required String fuelType,
    double? odometer,
    double? pricePerLiter,
    double? totalPrice,
    double? liters,
    String? station,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado.');
    }

    final now = DateTime.now();

    final data = <String, dynamic>{
      'userId': user.uid,
      'vehicleId': vehicleId,
      'vehicleName': vehicleName,
      'dateTime': Timestamp.fromDate(dateTime),
      'fuelType': fuelType,
      'odometer': odometer,
      'pricePerLiter': pricePerLiter,
      'totalPrice': totalPrice,
      'liters': liters,
      'station': station,
      'createdAt': Timestamp.fromDate(now),
    };

    await _firestore.collection('fuels').add(data);
  }

  Future<void> updateFuel({
    required String id,
    required String vehicleId,
    required DateTime dateTime,
    required String fuelType,
    double? odometer,
    double? pricePerLiter,
    double? totalPrice,
    double? liters,
    String? station,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado.');
    }

    final data = <String, dynamic>{
      'userId': user.uid,
      'vehicleId': vehicleId,
      'dateTime': Timestamp.fromDate(dateTime),
      'fuelType': fuelType,
      'odometer': odometer,
      'pricePerLiter': pricePerLiter,
      'totalPrice': totalPrice,
      'liters': liters,
      'station': station,
    };

    await _firestore.collection('fuels').doc(id).update(data);
  }

  Future<void> deleteFuel(String id) async {
    await _firestore.collection('fuels').doc(id).delete();
  }

  /// Stream de abastecimentos por veículo, com id e ordenados (mais recentes primeiro)
  Stream<List<FuelRecord>> fuelsByVehicleStream(String vehicleId) {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream<List<FuelRecord>>.empty();
    }

    return _firestore
        .collection('fuels')
        .where('userId', isEqualTo: user.uid)
        .where('vehicleId', isEqualTo: vehicleId)
        .snapshots()
        .map((snap) {
          final docs = snap.docs
              .map((d) => FuelRecord(id: d.id, data: d.data()))
              .toList();

          docs.sort((a, b) {
            final ta = a.data['dateTime'] as Timestamp?;
            final tb = b.data['dateTime'] as Timestamp?;
            final ma = ta?.millisecondsSinceEpoch ?? 0;
            final mb = tb?.millisecondsSinceEpoch ?? 0;
            return mb.compareTo(ma);
          });

          return docs;
        });
  }

  /// Retorna todos os abastecimentos do usuário logado, ordenados por data (mais recente primeiro).
  Stream<List<Map<String, dynamic>>> fuelsByUserStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream<List<Map<String, dynamic>>>.empty();
    }

    return _firestore
        .collection('fuels')
        .where('userId', isEqualTo: user.uid)
        // sem orderBy pra não exigir índice; ordenamos no cliente
        .snapshots()
        .map((snap) {
          final list = snap.docs.map((d) => d.data()).toList();

          list.sort((a, b) {
            final ta = a['dateTime'] as Timestamp?;
            final tb = b['dateTime'] as Timestamp?;
            final ma = ta?.millisecondsSinceEpoch ?? 0;
            final mb = tb?.millisecondsSinceEpoch ?? 0;
            return mb.compareTo(ma); // desc (mais recente primeiro)
          });

          return list;
        });
  }
}
