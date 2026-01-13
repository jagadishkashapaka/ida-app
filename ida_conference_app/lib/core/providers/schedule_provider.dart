import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/session.dart';

// Schedule data provider
final scheduleProvider = Provider<Map<String, List<Session>>>((ref) {
  return {
    'day1': [
      const Session(
        id: '1',
        title: 'Registrations & Delegate Kit Collection',
        speakerName: 'Organizing Committee',
        time: '09:00 AM - 10:00 AM',
        hall: 'Lobby',
        description: 'Check-in and delegate kit collection',
        status: 'Registration',
        statusMessage:
            'Please collect your welcome kit from the registration desk.',
      ),
      const Session(
        id: '2',
        title: 'Hands-On Workshops (Endodontics / Prosthodontics / Lasers)',
        speakerName: 'Workshop Instructors',
        time: '09:30 AM - 11:00 AM',
        hall: 'Workshop Halls',
        description: 'Practical hands-on sessions',
      ),
      const Session(
        id: '3',
        title: 'Inauguration Ceremony',
        speakerName: 'Chief Guests',
        time: '10:00 AM - 11:00 AM',
        hall: 'Main Hall',
        description: 'Official conference inauguration',
      ),
      const Session(
        id: '4',
        title: 'Keynote Lecture – Emerging Trends in Dentistry',
        speakerName: 'Keynote Speaker',
        time: '11:45 AM - 01:15 PM', // Delayed by 15 mins
        hall: 'Main Hall',
        description: 'Exploring the future of dental practice',
        status: 'Delayed',
        statusMessage:
            'The Keynote session will start 15 mins late due to technical issues.',
      ),
      const Session(
        id: 'lunch',
        title: 'Lunch Break',
        speakerName: 'All Delegates',
        time: '01:15 PM - 02:15 PM', // Rescheduled
        hall: 'Dining Area',
        description: 'Networking lunch',
        status: 'Rescheduled',
        statusMessage:
            'Lunch will be served at 1:15 PM instead of 12:30 PM today.',
      ),
      const Session(
        id: '5',
        title: 'Scientific Paper & Poster Presentations',
        speakerName: 'Researchers',
        time: '02:00 PM - 05:00 PM',
        hall: 'Conference Halls',
        description: 'Academic presentations and research posters',
      ),
      const Session(
        id: '6',
        title: 'Banquet Dinner & Cultural Night',
        speakerName: 'All Participants',
        time: '08:00 PM - 11:00 PM',
        hall: 'Banquet Hall',
        description: 'Evening entertainment and dinner',
      ),
    ],
    'day2': [
      const Session(
        id: '7',
        title: 'Scientific Sessions – Expert Speakers',
        speakerName: 'Expert Speakers',
        time: '11:30 AM - 01:00 PM',
        hall: 'Main Hall',
        description: 'Expert lectures on advanced dental topics',
      ),
      const Session(
        id: '8',
        title: 'Panel Discussion – Future of Dental Practice',
        speakerName: 'Panel of Experts',
        time: '02:00 PM - 03:30 PM',
        hall: 'Main Hall',
        description: 'Discussion on future trends and challenges',
      ),
    ],
  };
});

// Current session provider (Live Now)
final currentSessionProvider = Provider<Session?>((ref) {
  final schedule = ref.watch(scheduleProvider);
  final now = DateTime.now();

  // Check day1 sessions (January 24, 2026)
  for (final session in schedule['day1']!) {
    final times = parseTimeRange(session.time, 1);
    if (times != null) {
      final start = times['start']!;
      final end = times['end']!;

      if (now.isAfter(start) && now.isBefore(end)) {
        return session;
      }
    }
  }

  // Check day2 sessions (January 25, 2026)
  for (final session in schedule['day2']!) {
    final times = parseTimeRange(session.time, 2);
    if (times != null) {
      final start = times['start']!;
      final end = times['end']!;

      if (now.isAfter(start) && now.isBefore(end)) {
        return session;
      }
    }
  }

  return null;
});

// Up next sessions provider
final upNextSessionsProvider = Provider<List<Session>>((ref) {
  final schedule = ref.watch(scheduleProvider);
  final now = DateTime.now();

  final upcomingSessions = <Map<String, dynamic>>[];

  // Check day1 sessions (January 24, 2026)
  for (final session in schedule['day1']!) {
    final times = parseTimeRange(session.time, 1);
    if (times != null) {
      final start = times['start']!;

      if (now.isBefore(start)) {
        upcomingSessions.add({'session': session, 'start': start});
      }
    }
  }

  // Check day2 sessions (January 25, 2026)
  for (final session in schedule['day2']!) {
    final times = parseTimeRange(session.time, 2);
    if (times != null) {
      final start = times['start']!;

      if (now.isBefore(start)) {
        upcomingSessions.add({'session': session, 'start': start});
      }
    }
  }

  // Sort by start time and return top 2
  upcomingSessions.sort((a, b) {
    final aStart = a['start'] as DateTime;
    final bStart = b['start'] as DateTime;
    return aStart.compareTo(bStart);
  });

  return upcomingSessions
      .take(2)
      .map((item) => item['session'] as Session)
      .toList();
});

// Helper function to parse time range
Map<String, DateTime>? parseTimeRange(String timeRange, int day) {
  try {
    final parts = timeRange.split(' - ');
    if (parts.length != 2) return null;

    final start = parseTime(parts[0].trim(), day);
    final end = parseTime(parts[1].trim(), day);

    if (start == null || end == null) return null;

    return {'start': start, 'end': end};
  } catch (e) {
    return null;
  }
}

// Helper function to parse time string
DateTime? parseTime(String timeStr, int day) {
  try {
    final parts = timeStr.split(' ');
    if (parts.length != 2) return null;

    final timeParts = parts[0].split(':');
    if (timeParts.length != 2) return null;

    var hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final isPM = parts[1].toUpperCase() == 'PM';

    if (isPM && hour != 12) {
      hour += 12;
    } else if (!isPM && hour == 12) {
      hour = 0;
    }

    // Day 1 = January 24, 2026; Day 2 = January 25, 2026
    final conferenceDay = day == 1 ? 24 : 25;

    return DateTime(2026, 1, conferenceDay, hour, minute);
  } catch (e) {
    return null;
  }
}
