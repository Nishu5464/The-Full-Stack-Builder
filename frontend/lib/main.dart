import 'package:flutter/material.dart';
import 'screens/task_list_screen.dart';

void main() {
  runApp(const TaskApp());
}

class TaskApp extends StatefulWidget {
  const TaskApp({super.key});

  @override
  State<TaskApp> createState() => _TaskAppState();
}

class _TaskAppState extends State<TaskApp> {
  bool isDark = false;

  void toggleTheme() {
    setState(() {
      isDark = !isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task App',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: TaskListScreen(toggleTheme: toggleTheme),
    );
  }
}