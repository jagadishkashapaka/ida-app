import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/updates_provider.dart';
import '../services/notification_service.dart';

class NotificationObserver extends ConsumerStatefulWidget {
  final Widget child;
  const NotificationObserver({super.key, required this.child});

  @override
  ConsumerState<NotificationObserver> createState() => _NotificationObserverState();
}

class _NotificationObserverState extends ConsumerState<NotificationObserver> {
  @override
  Widget build(BuildContext context) {
    // We listen to the provider to detect changes
    ref.listen(announcementsProvider, (previous, next) {
      if (previous != null && next.length > previous.length) {
        // Find the new items
        final newItems = next.where((n) => !previous.any((p) => p.id == n.id)).toList();
        
        for (final item in newItems) {
           // Only notify if it's very recent (less than 1 min old) 
           // to avoid spamming on app restart/sync
           if (item.timestamp.isAfter(DateTime.now().subtract(const Duration(minutes: 1)))) {
             ref.read(notificationServiceProvider).showImmediateNotification(
               title: item.title,
               body: item.body,
             );
           }
        }
      }
    });

    return widget.child;
  }
}
