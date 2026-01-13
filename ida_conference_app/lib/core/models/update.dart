class Update {
  final String title;
  final String body;
  final DateTime timestamp;
  final String? sessionId;

  const Update({
    required this.title,
    required this.body,
    required this.timestamp,
    this.sessionId,
  });
}
