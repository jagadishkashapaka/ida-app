import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme.dart';
import 'core/router.dart';
import 'core/services/notification_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:firebase_messaging/firebase_messaging.dart';

// Background handler must be top-level
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // We don't need to show local notification here because FCM automatically
  // handling background messages on Android/iOS via system tray.
  // Unless it's a data-only message, which is rare for basic console usage.
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Register background handler (Not supported on Web in this way)
    if (!kIsWeb) {
       FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    }
    
    final container = ProviderContainer();
    
    // Initialize notifications (silently catch errors so app doesn't crash)
    try {
      await container.read(notificationServiceProvider).init();
    } catch (e) {
      debugPrint('Notification init failed: $e');
    }
    
    runApp(UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ));
  } catch (e) {
    // Fallback if critical init fails
    debugPrint('Critical init failed: $e');
    runApp(const MaterialApp(home: Scaffold(body: Center(child: Text("App Initialization Error")))));
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    // Trigger notification scheduling
    ref.watch(scheduleNotificationsProvider);

    return MaterialApp.router(
      title: 'IDA Conference',
      theme: appTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
