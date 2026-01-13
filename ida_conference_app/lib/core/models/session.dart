class Session {
  final String id;
  final String title;
  final String speakerName;
  final String time;
  final String hall;
  final String description;
  final String? status; // e.g., 'Delayed', 'Rescheduled', 'Moved'
  final String? statusMessage; // Detailed message for the update

  const Session({
    required this.id,
    required this.title,
    required this.speakerName,
    required this.time,
    required this.hall,
    required this.description,
    this.status,
    this.statusMessage,
  });
}
