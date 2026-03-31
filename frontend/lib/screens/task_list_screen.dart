import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import 'task_form_screen.dart';

class TaskListScreen extends StatefulWidget {
  final VoidCallback toggleTheme;

  const TaskListScreen({super.key, required this.toggleTheme});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> tasks = [];
  List<Task> filteredTasks = [];

  bool isLoading = true;
  String searchQuery = "";
  String selectedFilter = "All";

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    setState(() => isLoading = true);

    final data = await ApiService.fetchTasks();
    tasks = data;
    applyFilters();

    setState(() => isLoading = false);
  }

  void applyFilters() {
    List<Task> temp = tasks;

    if (selectedFilter != "All") {
      temp = temp.where((t) => t.status == selectedFilter).toList();
    }

    if (searchQuery.isNotEmpty) {
      temp = temp.where((t) =>
          t.title.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    }

    setState(() => filteredTasks = temp);
  }

  void openForm({Task? task}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaskFormScreen(task: task),
      ),
    );

    if (result != null && result is Task) {
      if (task == null) {
        await ApiService.addTask(result);
        showSnack("Task Added ✅");
      } else {
        await ApiService.updateTask(result);
        showSnack("Task Updated ✏️");
      }
      await loadTasks();
    }
  }

  void deleteTask(int id) async {
    await ApiService.deleteTask(id);
    showSnack("Task Deleted 🗑️");
    await loadTasks();
  }

  // ✅ Toggle status using checkbox
  void toggleStatus(Task t) async {
    final updated = Task(
      id: t.id,
      title: t.title,
      description: t.description,
      status: t.status == "Done" ? "To-Do" : "Done",
      dueDate: t.dueDate,
      blockedBy: t.blockedBy,
    );

    await ApiService.updateTask(updated);
    await loadTasks();
  }

  void showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
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

  int get total => tasks.length;
  int get done => tasks.where((t) => t.status == "Done").length;
  int get pending => tasks.where((t) => t.status != "Done").length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Task Manager"),
        actions: [
          IconButton(
            icon: const Icon(Icons.dark_mode),
            onPressed: widget.toggleTheme,
          )
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => openForm(),
        child: const Icon(Icons.add),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 📊 DASHBOARD
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceEvenly,
                    children: [
                      _statBox("Total", total, Colors.blue),
                      _statBox("Done", done, Colors.green),
                      _statBox("Pending", pending, Colors.red),
                    ],
                  ),
                ),

                // 🔍 SEARCH
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: "Search...",
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (val) {
                      searchQuery = val;
                      applyFilters();
                    },
                  ),
                ),

                // 🎯 FILTERS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ["All", "To-Do", "In Progress", "Done"]
                      .map((f) => ChoiceChip(
                            label: Text(f),
                            selected: selectedFilter == f,
                            onSelected: (_) {
                              selectedFilter = f;
                              applyFilters();
                            },
                          ))
                      .toList(),
                ),

                const SizedBox(height: 10),

                // 📋 LIST
                Expanded(
                  child: filteredTasks.isEmpty
                      ? const Center(child: Text("No Tasks"))
                      : ListView.builder(
                          itemCount: filteredTasks.length,
                          itemBuilder: (context, i) {
                            final t = filteredTasks[i];
                            final color =
                                getStatusColor(t.status);

                            return Dismissible(
                              key: Key(t.id.toString()),
                              onDismissed: (_) =>
                                  deleteTask(t.id!),
                              background: Container(
                                margin:
                                    const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6),
                                alignment: Alignment.centerRight,
                                padding:
                                    const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.delete,
                                    color: Colors.white),
                              ),
                              child: GestureDetector(
                                onLongPress: () =>
                                    openForm(task: t),
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(12),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 4,
                                      )
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      // 🔥 LEFT COLOR BAR
                                      Container(
                                        width: 5,
                                        height: 70,
                                        decoration: BoxDecoration(
                                          color: color,
                                          borderRadius:
                                              const BorderRadius
                                                  .only(
                                            topLeft:
                                                Radius.circular(12),
                                            bottomLeft:
                                                Radius.circular(12),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 10),

                                      // ✅ CHECKBOX
                                      Checkbox(
                                        value:
                                            t.status == "Done",
                                        onChanged: (_) =>
                                            toggleStatus(t),
                                      ),

                                      // TEXT
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                          children: [
                                            Text(
                                              t.title,
                                              style:
                                                  const TextStyle(
                                                fontWeight:
                                                    FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(
                                                height: 4),
                                            Text(
                                              t.description ??
                                                  "No description",
                                              style:
                                                  const TextStyle(
                                                      color:
                                                          Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(width: 10),

                                      // STATUS CHIP
                                      Container(
                                        margin:
                                            const EdgeInsets
                                                .only(right: 10),
                                        padding:
                                            const EdgeInsets
                                                .symmetric(
                                                    horizontal: 10,
                                                    vertical: 5),
                                        decoration:
                                            BoxDecoration(
                                          color: color
                                              .withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius
                                                  .circular(10),
                                        ),
                                        child: Text(
                                          t.status,
                                          style: TextStyle(
                                            color: color,
                                            fontWeight:
                                                FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _statBox(String title, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text("$count",
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          Text(title),
        ],
      ),
    );
  }
}