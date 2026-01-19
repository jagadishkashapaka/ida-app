import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/session.dart';
import '../models/update.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Sessions ---

  Stream<Map<String, List<Session>>> getScheduleStream() {
    debugPrint('🔗 Subscribing to schedule stream');
    return _db.collection('schedule').snapshots().map((snapshot) {
      final Map<String, List<Session>> schedule = {
        'day1': [],
        'day2': [],
      };
      for (var doc in snapshot.docs) {
        final day = doc.id; // 'day1', 'day2'
        final List<dynamic> sessionList = doc.data()['sessions'] ?? [];
        schedule[day] = sessionList
            .map((s) => Session.fromJson(s as Map<String, dynamic>))
            .toList();
      }
      debugPrint('📊 Schedule stream emitted - Day1: ${schedule['day1']?.length ?? 0}, Day2: ${schedule['day2']?.length ?? 0}');
      return schedule;
    });
  }

  Future<bool> doesScheduleExist() async {
    debugPrint('🔍 Checking if schedule exists in Firestore');
    final snapshot = await _db.collection('schedule').get();
    final exists = snapshot.docs.isNotEmpty;
    debugPrint('📋 Schedule exists: $exists');
    return exists;
  }

  Future<void> updateSchedule(String day, List<Session> sessions) async {
    debugPrint('💾 Updating schedule in Firestore - $day: ${sessions.length} sessions');
    await _db.collection('schedule').doc(day).set({
      'sessions': sessions.map((s) => s.toJson()).toList(),
    });
    debugPrint('✅ Schedule updated successfully - $day');
  }

  // --- Announcements ---

  Stream<List<Update>> getAnnouncementsStream() {
    debugPrint('🔗 Subscribing to announcements stream');
    return _db
        .collection('announcements')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      final updates = snapshot.docs.map((doc) {
        final data = doc.data();
        return Update(
          id: doc.id,
          title: data['title'] ?? '',
          body: data['body'] ?? '',
          timestamp: (data['timestamp'] as Timestamp).toDate(),
          sessionId: data['sessionId'],
        );
      }).toList();
      debugPrint('📊 Announcements stream emitted: ${updates.length} items');
      return updates;
    });
  }

  Future<void> addAnnouncement(Update update) async {
    debugPrint('💾 Adding announcement to Firestore: ${update.title}');
    await _db.collection('announcements').doc(update.id).set({
      'title': update.title,
      'body': update.body,
      'timestamp': Timestamp.fromDate(update.timestamp),
      'sessionId': update.sessionId,
    });
    debugPrint('✅ Announcement added successfully: ${update.id}');
  }

  Future<void> removeAnnouncement(String id) async {
    debugPrint('🗑️ Removing announcement from Firestore: $id');
    await _db.collection('announcements').doc(id).delete();
    debugPrint('✅ Announcement removed successfully: $id');
  }
}
