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

  void _submit() {
    if (titleController.text.trim().isEmpty) return;

    final task = Task(
      id: widget.task?.id,
      title: titleController.text,
      description: descController.text,
      status: status,
      // ❌ DO NOT SEND dueDate / extra fields
    );

    Navigator.pop(context, task);
  }

  InputDecoration inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "Done":
        return Colors.green;
      case "In Progress":
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = getStatusColor(status);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? "Add Task" : "Edit Task"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // CARD UI
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 6)
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: titleController,
                    decoration: inputStyle("Title"),
                  ),
                  const SizedBox(height: 15),

                  TextField(
                    controller: descController,
                    maxLines: 3,
                    decoration: inputStyle("Description"),
                  ),
                  const SizedBox(height: 15),

                  DropdownButtonFormField<String>(
                    value: status,
                    items: ["To-Do", "In Progress", "Done"]
                        .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s),
                            ))
                        .toList(),
                    onChanged: (val) {
                      setState(() => status = val!);
                    },
                    decoration: inputStyle("Status"),
                  ),

                  const SizedBox(height: 15),

                  // STATUS PREVIEW
                  Row(
                    children: [
                      const Text("Status: "),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.save),
                label: const Text("Save Task"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}