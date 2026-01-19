import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/session.dart';
import '../models/update.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Sessions ---

  Stream<Map<String, List<Session>>> getScheduleStream() {
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
      return schedule;
    });
  }

  Future<bool> doesScheduleExist() async {
    final snapshot = await _db.collection('schedule').get();
    return snapshot.docs.isNotEmpty;
  }

  Future<void> updateSchedule(String day, List<Session> sessions) async {
    await _db.collection('schedule').doc(day).set({
      'sessions': sessions.map((s) => s.toJson()).toList(),
    });
  }

  // --- Announcements ---

  Stream<List<Update>> getAnnouncementsStream() {
    return _db
        .collection('announcements')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Update(
          id: doc.id,
          title: data['title'] ?? '',
          body: data['body'] ?? '',
          timestamp: (data['timestamp'] as Timestamp).toDate(),
          sessionId: data['sessionId'],
        );
      }).toList();
    });
  }

  Future<void> addAnnouncement(Update update) async {
    await _db.collection('announcements').doc(update.id).set({
      'title': update.title,
      'body': update.body,
      'timestamp': Timestamp.fromDate(update.timestamp),
      'sessionId': update.sessionId,
    });
  }

  Future<void> removeAnnouncement(String id) async {
    await _db.collection('announcements').doc(id).delete();
  }
}
