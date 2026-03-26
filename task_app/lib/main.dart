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
  List tasks = [];
  TextEditingController controller = TextEditingController();

  final String baseUrl = "http://127.0.0.1:8000";

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  fetchTasks() async {
    var res = await http.get(Uri.parse("$baseUrl/tasks"));
    setState(() {
      tasks = json.decode(res.body);
    });
  }

  addTask() async {
    if (controller.text.isEmpty) return;
    await http.post(Uri.parse("$baseUrl/tasks?title=${controller.text}"));
    controller.clear();
    fetchTasks();
  }

  deleteTask(int id) async {
    await http.delete(Uri.parse("$baseUrl/tasks/$id"));
    fetchTasks();
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
                  return Card(
                    child: ListTile(
                      title: Text(tasks[i]['title']),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
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