import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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

    // Local Notification Setup
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

    // FCM Setup (Skip on Web for now to avoid crashes if SW missing)
    if (!kIsWeb) {
      await _initFCM();
    }
  }

  Future<void> _initFCM() async {
    // Request permission (Apple)
    final settings = await FirebaseMessaging.instance.requestPermission();
    debugPrint('User granted permission: ${settings.authorizationStatus}');
    
    // Get and log token
    final fcmToken = await FirebaseMessaging.instance.getToken();
    debugPrint('FCM Token: $fcmToken');
    
    // Subscribe to topic
    await FirebaseMessaging.instance.subscribeToTopic('announcements');
    debugPrint('Subscribed to announcements topic');
    
    // Create the channel explicitly for Android
    const androidChannel = AndroidNotificationChannel(
      'announcement_channel', // id
      'Announcements', // title
      description: 'Important announcements from admin', // description
      importance: Importance.max,
    );
    
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    // Foreground Message Handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        showImmediateNotification(
          title: message.notification!.title ?? 'New Announcement',
          body: message.notification!.body ?? '',
        );
      }
    });
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
          icon: '@mipmap/launcher_icon', // Use app launcher icon
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> showImmediateNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'announcement_channel',
      'Announcements',
      channelDescription: 'Important announcements from admin',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon', // Use app launcher icon
    );
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );
    await _notificationsPlugin.show(
      DateTime.now().millisecond, // unique id
      title,
      body,
      notificationDetails,
    );
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  Future<void> scheduleAllSessions(Map<String, List<Session>> schedule) async {
    await cancelAllNotifications();
    
    // Ensure we are using the correct location for the conference
    final indiaLocation = tz.getLocation('Asia/Kolkata');
    tz.setLocalLocation(indiaLocation);

    int notificationId = 0;
    // Current time in India
    final now = tz.TZDateTime.now(indiaLocation);

    schedule.forEach((dayKey, sessions) {
      final dayNum = dayKey == 'day1' ? 1 : 2;
      for (final session in sessions) {
        final times = parseTimeRange(session.time, dayNum);
        if (times != null) {
          final startTime = times['start']!;
          // Reconstruct as TZDateTime in India timezone to ensure absolute correct time
          // regardless of user's device timezone.
          final sessionStartIST = tz.TZDateTime(
            indiaLocation,
            startTime.year,
            startTime.month,
            startTime.day,
            startTime.hour,
            startTime.minute,
          );

          // Schedule 5 minutes before the session starts
          final scheduleTime = sessionStartIST.subtract(const Duration(minutes: 5));

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
