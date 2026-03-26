import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(TaskApp());
}

class TaskApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TaskScreen(),
    );
  }
}

class TaskScreen extends StatefulWidget {
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  List<dynamic> tasks = [];
  TextEditingController controller = TextEditingController();

  // ✅ FIXED: 10.0.2.2 for Android emulator
  // ✅ Physical device: replace with your PC's IP e.g. http://192.168.1.5:8000
  final String baseUrl = "http://10.0.2.2:8000";

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  // ✅ GET all tasks
  fetchTasks() async {
    try {
      var res = await http.get(Uri.parse("$baseUrl/tasks"));
      if (res.statusCode == 200) {
        setState(() {
          tasks = json.decode(res.body);
        });
      }
    } catch (e) {
      print("Error fetching tasks: $e");
    }
  }

  // ✅ POST — send JSON body
  addTask() async {
    if (controller.text.isEmpty) return;
    try {
      await http.post(
        Uri.parse("$baseUrl/tasks"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"title": controller.text}),
      );
      controller.clear();
      fetchTasks();
    } catch (e) {
      print("Error adding task: $e");
    }
  }

  // ✅ PUT — toggle pending/completed
  toggleTask(int id, String currentStatus) async {
    String newStatus = currentStatus == "pending" ? "completed" : "pending";
    try {
      await http.put(
        Uri.parse("$baseUrl/tasks/$id"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"status": newStatus}),
      );
      fetchTasks();
    } catch (e) {
      print("Error updating task: $e");
    }
  }

  // ✅ DELETE — remove task
  deleteTask(int id) async {
    try {
      await http.delete(Uri.parse("$baseUrl/tasks/$id"));
      fetchTasks();
    } catch (e) {
      print("Error deleting task: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Task Manager"),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: "Enter Task",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: addTask,
              child: Text("Add Task"),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (c, i) {
                  bool isCompleted = tasks[i]['status'] == 'completed';
                  return Card(
                    child: ListTile(
                      leading: Icon(
                        isCompleted
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: isCompleted ? Colors.green : Colors.grey,
                      ),
                      title: Text(
                        tasks[i]['title'],
                        style: TextStyle(
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      subtitle: Text(tasks[i]['status']),
                      onTap: () => toggleTask(tasks[i]['id'], tasks[i]['status']),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteTask(tasks[i]['id']),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}