import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Vehicle {
  final String id;
  final String type;
  final String name;
  final String brand;
  final String model;
  final String year;
  final String color;
  final String plate;
  final String fuel;
  final String tankVolume;
  final String? chassis;
  final String? renavam;

  Vehicle({
    required this.id,
    required this.type,
    required this.name,
    required this.brand,
    required this.model,
    required this.year,
    required this.color,
    required this.plate,
    required this.fuel,
    required this.tankVolume,
    this.chassis,
    this.renavam,
  });

  factory Vehicle.fromMap(String id, Map<String, dynamic> data) {
    return Vehicle(
      id: id,
      type: data['type'] ?? '',
      name: data['name'] ?? '',
      brand: data['brand'] ?? '',
      model: data['model'] ?? '',
      year: data['year'] ?? '',
      color: data['color'] ?? '',
      plate: data['plate'] ?? '',
      fuel: data['fuel'] ?? '',
      tankVolume: data['tankVolume'] ?? '',
      chassis: data['chassis'],
      renavam: data['renavam'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'name': name,
      'brand': brand,
      'model': model,
      'year': year,
      'color': color,
      'plate': plate,
      'fuel': fuel,
      'tankVolume': tankVolume,
      'chassis': chassis,
      'renavam': renavam,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

class VehicleService {
  VehicleService._();
  static final instance = VehicleService._();

  FirebaseFirestore get _db => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _userVehiclesCol() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado.');
    }
    return _db.collection('users').doc(user.uid).collection('vehicles');
  }

  Stream<List<Vehicle>> vehiclesStream() {
    return _userVehiclesCol()
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => Vehicle.fromMap(d.id, d.data())).toList(),
        );
  }

  Future<void> addVehicle(Vehicle v) async {
    await _userVehiclesCol().add(v.toMap());
  }

  Future<void> updateVehicle(Vehicle v) async {
    await _userVehiclesCol().doc(v.id).update(v.toMap());
  }

  Future<void> deleteVehicle(String id) async {
    await _userVehiclesCol().doc(id).delete();
  }
}
