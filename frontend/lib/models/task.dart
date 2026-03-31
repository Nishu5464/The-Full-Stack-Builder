class Task {
  int? id;
  String title;
  String description;
  String? dueDate;
  String status;
  int? blockedBy;

  Task({
    this.id,
    required this.title,
    required this.description,
    this.dueDate,
    required this.status,
    this.blockedBy,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? "",
      dueDate: json['due_date'], // 🔥 FIXED
      status: json['status'],
      blockedBy: json['blocked_by'], // 🔥 FIXED
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "description": description,
      "due_date": dueDate, // 🔥 FIXED
      "status": status,
      "blocked_by": blockedBy, // 🔥 FIXED
    };
  }
}