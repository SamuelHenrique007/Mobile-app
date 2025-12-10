import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    // timezone (importante para agendar na hora certa)
    tz.initializeTimeZones();
    // Se quiser, pode ajustar para 'America/Sao_Paulo'
    tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _plugin.initialize(
      initSettings,
      // onDidReceiveNotificationResponse: (details) { ... } // se quiser tratar clique
    );

    _initialized = true;
  }

  /// Agenda uma notificação para a data/hora informadas
  Future<void> scheduleReminderNotification({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
  }) async {
    await init(); // garante inicialização

    final tzDate = tz.TZDateTime.from(dateTime, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'reminders_channel',
      'Lembretes',
      channelDescription: 'Notificações de lembretes do DriveUP',
      importance: Importance.max,
      priority: Priority.high,
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzDate,
      const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  /// Cancela uma notificação específica
  Future<void> cancelNotification(int id) async {
    await init();
    await _plugin.cancel(id);
  }
}
