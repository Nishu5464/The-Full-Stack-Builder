import '../models/task.dart';

bool isTaskBlocked(Task t, List<Task> tasks) {
  if (t.blockedBy == null) return false;

  try {
    final blocker = tasks.firstWhere((e) => e.id == t.blockedBy);
    return blocker.status != "Done";
  } catch (e) {
    return false; // if blocker not found → assume not blocked
  }
}