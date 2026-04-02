import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;

  const TaskFormScreen({super.key, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  late TextEditingController titleController;
  late TextEditingController descController;

  String status = "To-Do";

  @override
  void initState() {
    super.initState();

    titleController =
        TextEditingController(text: widget.task?.title ?? "");
    descController =
        TextEditingController(text: widget.task?.description ?? "");
    status = widget.task?.status ?? "To-Do";
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  void _submit() {
    if (titleController.text.trim().isEmpty) return;

    final task = Task(
      id: widget.task?.id,
      title: titleController.text.trim(),
      description: descController.text.trim(),
      status: status,
    );

    Navigator.pop(context, task);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? "Add Task" : "Edit Task"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descController,
              decoration:
                  const InputDecoration(labelText: "Description"),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: status,
              items: ["To-Do", "In Progress", "Done"]
                  .map((s) =>
                      DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) => setState(() => status = val!),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: const Text("Save"),
            )
          ],
        ),
      ),
    );
  }
}