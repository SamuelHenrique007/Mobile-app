import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:driveup/services/notification_service.dart';

class Reminder {
  final String id;
  final String title;
  final DateTime dateTime;
  final String? vehicleId;
  final String? vehicleName;
  final bool done;
  final int notificationId;

  Reminder({
    required this.id,
    required this.title,
    required this.dateTime,
    this.vehicleId,
    this.vehicleName,
    required this.done,
    required this.notificationId,
  });

  factory Reminder.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final ts = data['dateTime'] as Timestamp?;
    return Reminder(
      id: doc.id,
      title: (data['title'] ?? '') as String,
      dateTime: ts?.toDate() ?? DateTime.now(),
      vehicleId: data['vehicleId'] as String?,
      vehicleName: data['vehicleName'] as String?,
      done: (data['done'] ?? false) as bool,
      notificationId: (data['notificationId'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'dateTime': Timestamp.fromDate(dateTime),
      'vehicleId': vehicleId,
      'vehicleName': vehicleName,
      'done': done,
      'notificationId': notificationId,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

class ReminderService {
  ReminderService._();
  static final ReminderService instance = ReminderService._();

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Usuário não autenticado');
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('users').doc(_uid).collection('reminders');

  /// Lê TODOS os lembretes (útil para debug, se quiser ver futuros também)
  Stream<List<Reminder>> remindersStreamRaw() {
    return _col
        .orderBy('dateTime')
        .snapshots()
        .map((snap) => snap.docs.map(Reminder.fromDoc).toList());
  }

  /// Só retorna lembretes cujo horário JÁ CHEGOU (dateTime <= agora)
  Stream<List<Reminder>> activeRemindersStream() {
    return remindersStreamRaw().map((list) {
      final now = DateTime.now();
      return list.where((r) => !r.dateTime.isAfter(now)).toList();
    });
  }

  /// Cria lembrete e agenda notificação
  Future<void> createReminder({
    required String title,
    required DateTime dateTime,
    String? vehicleId,
    String? vehicleName,
  }) async {
    // id numérico "estável" para o plugin de notificação
    final notificationId = dateTime.millisecondsSinceEpoch.remainder(
      1000000000,
    );

    final reminder = Reminder(
      id: '',
      title: title,
      dateTime: dateTime,
      vehicleId: vehicleId,
      vehicleName: vehicleName,
      done: false,
      notificationId: notificationId,
    );

    // salva no Firestore
    await _col.add(reminder.toMap());

    // monta corpo da notificação
    var body = 'Lembrete agendado para ${_formatDateTime(dateTime)}.';
    if (vehicleName != null && vehicleName.trim().isNotEmpty) {
      body += ' Veículo: $vehicleName.';
    }

    // agenda notificação local
    await NotificationService.instance.scheduleReminderNotification(
      id: notificationId,
      title: title,
      body: body,
      dateTime: dateTime,
    );
  }

  /// Marca como concluído / pendente
  Future<void> toggleDone(Reminder r) async {
    final newValue = !r.done;
    await _col.doc(r.id).update({'done': newValue});

    // Se marcou como concluído, podemos cancelar notificação futura (se ainda não disparou)
    if (newValue == true) {
      await NotificationService.instance.cancelNotification(r.notificationId);
    }
  }

  /// Exclui lembrete e cancela notificação
  Future<void> deleteReminder(String id) async {
    final docRef = _col.doc(id);
    final snap = await docRef.get();
    if (snap.exists) {
      final data = snap.data();
      final notifId = (data?['notificationId'] ?? 0) as int;
      if (notifId != 0) {
        await NotificationService.instance.cancelNotification(notifId);
      }
    }
    await docRef.delete();
  }

  String _formatDateTime(DateTime d) {
    final date =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    final time =
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    return '$date às $time';
  }
}
