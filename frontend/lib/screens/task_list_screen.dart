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
      temp = temp
          .where((t) =>
              t.title.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
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

  Future<bool> deleteTask(int id) async {
    final success = await ApiService.deleteTask(id);
    if (success) {
      showSnack("Task Deleted 🗑️");
      await loadTasks();
      return true;
    }
    return false;
  }

  void toggleStatus(Task t) async {
    final updated =
        t.copyWith(status: t.status == "Done" ? "To-Do" : "Done");
    await ApiService.updateTask(updated);
    await loadTasks();
  }

  void showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
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
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
            ),
          ),
        ),
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
          : RefreshIndicator(
              onRefresh: loadTasks,
              child: Column(
                children: [
                  // 📊 Stats Cards
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _statCard("Total", total, Colors.blue),
                        _statCard("Done", done, Colors.green),
                        _statCard("Pending", pending, Colors.red),
                      ],
                    ),
                  ),

                  // 🔍 Search
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search...",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (val) {
                        searchQuery = val;
                        applyFilters();
                      },
                    ),
                  ),

                  // 🎯 Filters
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ["All", "To-Do", "In Progress", "Done"]
                        .map((f) => ChoiceChip(
                              label: Text(f),
                              selected: selectedFilter == f,
                              onSelected: (_) {
                                setState(() => selectedFilter = f);
                                applyFilters();
                              },
                            ))
                        .toList(),
                  ),

                  const SizedBox(height: 10),

                  // 📋 List / Empty
                  Expanded(
                    child: filteredTasks.isEmpty
                        ? _emptyState()
                        : ListView.builder(
                            itemCount: filteredTasks.length,
                            itemBuilder: (context, i) {
                              final t = filteredTasks[i];

                              return Dismissible(
                                key: Key(t.id.toString()),
                                direction: DismissDirection.endToStart,
                                confirmDismiss: (_) async =>
                                    await deleteTask(t.id!),
                                background: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerRight,
                                  padding:
                                      const EdgeInsets.only(right: 20),
                                  child: const Icon(Icons.delete,
                                      color: Colors.white),
                                ),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  child: ListTile(
                                    title: Text(
                                      t.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        decoration: t.status == "Done"
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                    subtitle: Text(
                                        t.description ?? "No description"),
                                    trailing: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4),
                                          decoration: BoxDecoration(
                                            color: getStatusColor(
                                                    t.status)
                                                .withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            t.status,
                                            style: TextStyle(
                                              color: getStatusColor(
                                                  t.status),
                                            ),
                                          ),
                                        ),
                                        Checkbox(
                                          value: t.status == "Done",
                                          onChanged: (_) =>
                                              toggleStatus(t),
                                        )
                                      ],
                                    ),
                                    onTap: () => openForm(task: t),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _statCard(String title, int count, Color color) {
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            Text("$count",
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
            Text(title),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.task_alt, size: 70, color: Colors.grey),
          SizedBox(height: 15),
          Text("No Tasks Yet",
              style:
                  TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 5),
          Text("Add your first task 🚀",
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}