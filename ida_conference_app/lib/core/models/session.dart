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
  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] as String,
      title: json['title'] as String,
      speakerName: json['speakerName'] as String,
      time: json['time'] as String,
      hall: json['hall'] as String,
      description: json['description'] as String? ?? '',
      status: json['status'] as String?,
      statusMessage: json['statusMessage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'speakerName': speakerName,
      'time': time,
      'hall': hall,
      'description': description,
      'status': status,
      'statusMessage': statusMessage,
    };
  }
}
