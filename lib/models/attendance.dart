class Attendance {
  final String id;
  final DateTime date;
  final String subject;
  final bool isPresent;
  final int studyDuration; // in minutes

  Attendance({
    required this.id,
    required this.date,
    required this.subject,
    required this.isPresent,
    required this.studyDuration,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'subject': subject,
      'isPresent': isPresent,
      'studyDuration': studyDuration,
    };
  }

  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      id: map['id'],
      date: DateTime.parse(map['date']),
      subject: map['subject'],
      isPresent: map['isPresent'],
      studyDuration: map['studyDuration'],
    );
  }
}