import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/update.dart';
import 'schedule_provider.dart';

final updatesProvider = Provider<List<Update>>((ref) {
  final schedule = ref.watch(scheduleProvider);
  final updates = <Update>[];
  final now = DateTime.now();

  // Automatically generate updates from Schedule (Dynamic)
  // Scan all days for sessions with status updates
  for (final entry in schedule.entries) {
    final dayKey = entry.key; // 'day1' or 'day2'
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

        // Get actual scheduled start time
        final times = parseTimeRange(session.time, dayIndex);
        if (times != null) {
          final timestamp = times['start']!;

          // Only show updates that have "happened" according to current time
          // For testing, you might want to comment out this 'if'
          if (now.isAfter(timestamp)) {
            updates.add(
              Update(
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
