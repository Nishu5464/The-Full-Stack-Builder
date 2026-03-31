import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';

class ApiService {
  static const String baseUrl = "http://localhost:8000";

  // GET TASKS
  static Future<List<Task>> fetchTasks() async {
    final res = await http.get(Uri.parse("$baseUrl/tasks"));

    print("GET STATUS: ${res.statusCode}");
    print("GET BODY: ${res.body}");

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Task.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load tasks");
    }
  }

  // ADD TASK
  static Future<void> addTask(Task task) async {
    final res = await http.post(
      Uri.parse("$baseUrl/tasks"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(task.toJson()),
    );

    print("🔥 ADD STATUS: ${res.statusCode}");
    print("🔥 ADD BODY: ${res.body}");

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception("Failed to add task");
    }
  }

  // UPDATE TASK
  static Future<void> updateTask(Task task) async {
    if (task.id == null) {
      throw Exception("Task ID is null");
    }

    final res = await http.put(
      Uri.parse("$baseUrl/tasks/${task.id}"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(task.toJson()),
    );

    print("🔥 UPDATE STATUS: ${res.statusCode}");
    print("🔥 UPDATE BODY: ${res.body}");

    if (res.statusCode != 200) {
      throw Exception("Failed to update task");
    }
  }

  // DELETE TASK
  static Future<void> deleteTask(int id) async {
    final res =
        await http.delete(Uri.parse("$baseUrl/tasks/$id"));

    print("DELETE STATUS: ${res.statusCode}");

    if (res.statusCode != 200) {
      throw Exception("Failed to delete task");
    }
  }
}