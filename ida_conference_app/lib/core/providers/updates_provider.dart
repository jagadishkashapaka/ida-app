import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/update.dart';
import '../services/firestore_service.dart';
import 'schedule_provider.dart';

// Manual announcements provider
class AnnouncementsNotifier extends Notifier<List<Update>> {
  final _firestoreService = FirestoreService();

  @override
  List<Update> build() {
    // Listen to real-time updates
    // CRITICAL: Store subscription to prevent garbage collection
    final subscription = _firestoreService.getAnnouncementsStream().listen(
      (updates) {
        debugPrint('📥 Announcements update received from Firestore: ${updates.length} items');
        state = updates;
      },
      onError: (e) {
        debugPrint('❌ Announcements Sync Error: $e');
      },
    );
    
    // Ensure subscription is cancelled when provider is disposed
    ref.onDispose(() {
      debugPrint('🔌 Cancelling announcements stream subscription');
      subscription.cancel();
    });
    
    return [];
  }

  Future<void> addAnnouncement(String title, String body) async {
    final update = Update(
      id: 'ann_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      timestamp: DateTime.now(),
    );
    
    // Optimistic update
    state = [...state, update];
    
    await _firestoreService.addAnnouncement(update);
  }

  Future<void> removeAnnouncement(String id) async {
    state = state.where((ann) => ann.id != id).toList();
    await _firestoreService.removeAnnouncement(id);
  }
}

final announcementsProvider =
    NotifierProvider<AnnouncementsNotifier, List<Update>>(AnnouncementsNotifier.new);

// Combined updates provider
final updatesProvider = Provider<List<Update>>((ref) {
  final schedule = ref.watch(scheduleProvider);
  final announcements = ref.watch(announcementsProvider);
  
  final updates = <Update>[...announcements];
  final now = DateTime.now();

  // Automatically generate updates from Schedule (Dynamic)
  for (final entry in schedule.entries) {
    final dayKey = entry.key;
    final dayIndex = dayKey == 'day1' ? 1 : 2;
    final sessions = entry.value;

    for (final session in sessions) {
      if (session.status != null && session.statusMessage != null) {
        String title = 'Schedule Update';
        if (session.id == '1') {
          title = 'Welcome Kit';
        } else if (session.status == 'Delayed') {
          title = 'Session Delayed: ${session.title}';
        } else if (session.id == 'lunch') {
          title = 'Lunch Time Change';
        }

        final times = parseTimeRange(session.time, dayIndex);
        if (times != null) {
          final timestamp = times['start']!;
          if (now.isAfter(timestamp)) {
            updates.add(
              Update(
                id: 'sched_${session.id}_${timestamp.millisecondsSinceEpoch}',
                title: title,
                body: session.statusMessage!,
                timestamp: timestamp,
                sessionId: session.id,
              ),
            );
          }
        }
      }
    }
  }

  // Sort by timestamp (newest first)
  updates.sort((a, b) => b.timestamp.compareTo(a.timestamp));

  return updates;
});
