class Task {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String type;
  final bool isCompleted;
  final String userEmail;  // Add this field

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.type,
    required this.userEmail,  // Add this parameter
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'type': type,
      'isCompleted': isCompleted,
      'userEmail': userEmail,  // Add this field
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      dueDate: DateTime.parse(map['dueDate']),
      type: map['type'],
      userEmail: map['userEmail'],  // Add this field
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}