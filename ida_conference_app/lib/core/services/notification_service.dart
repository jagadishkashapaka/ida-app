import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/session.dart';
import '../providers/schedule_provider.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
      },
    );
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'conference_channel',
          'Conference Notifications',
          channelDescription: 'Notifications for upcoming conference sessions',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  Future<void> scheduleAllSessions(Map<String, List<Session>> schedule) async {
    await cancelAllNotifications();
    
    int notificationId = 0;
    final now = DateTime.now();

    schedule.forEach((dayKey, sessions) {
      final dayNum = dayKey == 'day1' ? 1 : 2;
      for (final session in sessions) {
        final times = parseTimeRange(session.time, dayNum);
        if (times != null) {
          final startTime = times['start']!;
          // Schedule 5 minutes before the session starts
          final scheduleTime = startTime.subtract(const Duration(minutes: 5));

          if (scheduleTime.isAfter(now)) {
            scheduleNotification(
              id: notificationId++,
              title: 'Upcoming Session: ${session.title}',
              body: 'In ${session.hall} with ${session.speakerName}',
              scheduledDate: scheduleTime,
            );
          }
        }
      }
    });
  }
}

final scheduleNotificationsProvider = FutureProvider<void>((ref) async {
  final schedule = ref.watch(scheduleProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  await notificationService.scheduleAllSessions(schedule);
});
