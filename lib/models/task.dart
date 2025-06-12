class Task {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String type;
  final bool isCompleted;
  final DateTime? completedAt;
  final String userEmail;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.type,
    required this.userEmail,
    this.isCompleted = false,
    this.completedAt,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? type,
    bool? isCompleted,
    DateTime? completedAt,
    String? userEmail,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      type: type ?? this.type,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      userEmail: userEmail ?? this.userEmail,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'type': type,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'userEmail': userEmail,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      dueDate: DateTime.parse(map['dueDate']),
      type: map['type'],
      isCompleted: map['isCompleted'] ?? false,
      completedAt: map['completedAt'] != null 
          ? DateTime.parse(map['completedAt'])
          : null,
      userEmail: map['userEmail'],
    );
  }
}