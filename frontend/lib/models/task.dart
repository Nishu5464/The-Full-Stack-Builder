class Task {
  final int? id;
  final String title;
  final String? description;
  final String status;

  // Optional fields (safe for backend compatibility)
  final String? dueDate;
  final int? blockedBy;

  Task({
    this.id,
    required this.title,
    this.description,
    required this.status,
    this.dueDate,
    this.blockedBy,
  });

  // ✅ Convert JSON → Task object
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'] ?? "",
      description: json['description'],
      status: json['status'] ?? "To-Do",
      dueDate: json['due_date'],     // matches FastAPI snake_case
      blockedBy: json['blocked_by'],
    );
  }

  // ✅ Convert Task → JSON (for API)
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "description": description,
      "status": status,

      // ⚠️ Only include if backend supports
      "due_date": dueDate,
      "blocked_by": blockedBy,
    };
  }

  // ✅ CopyWith (useful for updates)
  Task copyWith({
    int? id,
    String? title,
    String? description,
    String? status,
    String? dueDate,
    int? blockedBy,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      blockedBy: blockedBy ?? this.blockedBy,
    );
  }
}