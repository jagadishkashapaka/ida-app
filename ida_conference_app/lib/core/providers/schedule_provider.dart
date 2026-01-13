import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/session.dart';

// Schedule data provider
final scheduleProvider = Provider<Map<String, List<Session>>>((ref) {
  return {
    'day1': [
      const Session(
        id: '1',
        title: 'Bend without Breaking: Expert Strategies for Curved Canals',
        speakerName: 'Dr. Vijetha B',
        time: '09:30 AM - 10:00 AM',
        hall: 'Main Hall',
        description: 'Expert strategies for handling curved canals.',
      ),
      const Session(
        id: '2',
        title: 'Bruxism – Current Status and Restorative Implications',
        speakerName: 'Dr. Rangarajan V',
        time: '10:00 AM - 11:00 AM',
        hall: 'Main Hall',
        description: 'Current status and restorative implications of Bruxism.',
      ),
      const Session(
        id: '3',
        title:
            'Smart Decisions in Everyday Dentistry: Prevention to Restoration',
        speakerName: 'Dr. Sorna Nagarajan',
        time: '11:00 AM - 12:00 PM',
        hall: 'Main Hall',
        description: 'Making smart decisions in everyday dentistry.',
      ),
      const Session(
        id: '4',
        title: 'Corticobasal Implants – Myth or Reality',
        speakerName: 'Dr. Nemaly Chaithanyaa',
        time: '12:00 PM - 01:00 PM',
        hall: 'Main Hall',
        description: 'Exploring the reality of Corticobasal Implants.',
      ),
      const Session(
        id: '5',
        title: 'Illegally Legal',
        speakerName: 'Dr. Prahlad',
        time: '01:30 PM - 02:00 PM',
        hall: 'Main Hall',
        description: 'Legal aspects in dentistry.',
      ),
      const Session(
        id: '6',
        title: 'Digital Invasion in General Practice',
        speakerName: 'Dr. Mahendranadh Reddy',
        time: '02:00 PM - 03:00 PM',
        hall: 'Main Hall',
        description: 'The impact of digital technology in general practice.',
      ),
      const Session(
        id: '7',
        title: 'Inauguration',
        speakerName: 'Organizing Committee',
        time: '02:00 PM - 03:00 PM',
        hall: 'Main Hall',
        description: 'Official inauguration ceremony.',
      ),
      const Session(
        id: '8',
        title: 'Banquet Dinner & Cultural Night',
        speakerName: 'All Participants',
        time: '08:00 PM - 11:00 PM',
        hall: 'Banquet Hall',
        description: 'Evening entertainment and dinner.',
      ),
    ],
    'day2': [
      const Session(
        id: '9',
        title: 'Cracked Teeth – Diagnosis and Management',
        speakerName: 'Dr. Mamatha Koushik',
        time: '09:30 AM - 10:00 AM',
        hall: 'Main Hall',
        description: 'Diagnosis and Management of Cracked Teeth.',
      ),
      const Session(
        id: '10',
        title:
            'What Every Dentist Must See in 2026: Oral Blue C Paradigm Shift in Laser Care',
        speakerName: 'Dr. Chandra Shekar Yavagal',
        time: '10:00 AM - 11:00 AM',
        hall: 'Main Hall',
        description: 'Paradigm Shift in Laser Care.',
      ),
      const Session(
        id: '11',
        title: 'Shades Lighter, Smile Brighter – Teeth Whitening Demystified',
        speakerName: 'Dr. Santhosh Ravindra',
        time: '11:00 AM - 12:00 PM',
        hall: 'Main Hall',
        description: 'Teeth Whitening Demystified.',
      ),
      const Session(
        id: '12',
        title:
            'AIDS !! 3.0 Artificial Intelligence In Dental Care Sciences. 3.0',
        speakerName: 'Dr. Sarjeev Singh Yadav',
        time: '12:00 PM - 12:30 PM',
        hall: 'Main Hall',
        description: 'Artificial Intelligence In Dental Care Sciences.',
      ),
      const Session(
        id: '13',
        title: 'Invisalign',
        speakerName: 'Guest Speaker',
        time: '12:30 PM - 01:30 PM',
        hall: 'Main Hall',
        description: 'Session on Invisalign.',
      ),
      const Session(
        id: '14',
        title: 'Digital Marketing',
        speakerName: 'Dr. Mani Pavitra',
        time: '01:30 PM - 02:30 PM',
        hall: 'Main Hall',
        description: 'Digital Marketing in Dentistry.',
      ),
      const Session(
        id: '15',
        title: 'Validictory',
        speakerName: 'Organizing Committee',
        time: '02:30 PM - 03:30 PM',
        hall: 'Main Hall',
        description: 'Validictory Function.',
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
