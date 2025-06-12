class StudySession {
  final String id;
  final String subject;
  final DateTime startTime;
  final DateTime endTime;
  final int targetDuration;
  final List<String> completedTopics;
  final double progressPercentage;

  StudySession({
    required this.id,
    required this.subject,
    required this.startTime,
    required this.endTime,
    this.targetDuration = 60,
    this.completedTopics = const [],
    this.progressPercentage = 0.0,
  });

  Duration get duration => endTime.difference(startTime);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject': subject,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'targetDuration': targetDuration,
      'completedTopics': completedTopics,
      'progressPercentage': progressPercentage,
    };
  }

  factory StudySession.fromMap(Map<String, dynamic> map) {
    return StudySession(
      id: map['id'],
      subject: map['subject'],
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      targetDuration: map['targetDuration'] ?? 60,
      completedTopics: List<String>.from(map['completedTopics'] ?? []),
      progressPercentage: map['progressPercentage'] ?? 0.0,
    );
  }
}