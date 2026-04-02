import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';

class ApiService {
  static const String baseUrl = "http://localhost:8000";

  // ✅ GET TASKS (with timeout + safe handling)
  static Future<List<Task>> fetchTasks() async {
    try {
      final res = await http
          .get(Uri.parse("$baseUrl/tasks"))
          .timeout(const Duration(seconds: 5));

      print("GET STATUS: ${res.statusCode}");

      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        return data.map((e) => Task.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print("FETCH ERROR: $e");
      return [];
    }
  }

  // ✅ ADD TASK
  static Future<void> addTask(Task task) async {
    try {
      await http.post(
        Uri.parse("$baseUrl/tasks"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(task.toJson()),
      );
    } catch (e) {
      print("ADD ERROR: $e");
    }
  }

  // ✅ UPDATE TASK
  static Future<void> updateTask(Task task) async {
    try {
      await http.put(
        Uri.parse("$baseUrl/tasks/${task.id}"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(task.toJson()),
      );
    } catch (e) {
      print("UPDATE ERROR: $e");
    }
  }

  // ✅ DELETE TASK (fixed)
  static Future<bool> deleteTask(int id) async {
    try {
      final res = await http
          .delete(Uri.parse("$baseUrl/tasks/$id"))
          .timeout(const Duration(seconds: 5));

      print("DELETE STATUS: ${res.statusCode}");

      return res.statusCode == 200 || res.statusCode == 204;
    } catch (e) {
      print("DELETE ERROR: $e");
      return false;
    }
  }
}