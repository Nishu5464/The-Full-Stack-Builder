Widget buildTaskCard(Task task) {
  final date = DateTime.parse(task.dueDate);
  final blocked = isTaskBlocked(task);

  return Opacity(
    opacity: blocked ? 0.5 : 1,
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black12,
            offset: Offset(2, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LEFT SIDE
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  task.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 5),
                    Text(
                      date.toLocal().toString().split(' ')[0],
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: getStatusColor(task.status)
                            .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        task.status,
                        style: TextStyle(
                          color: getStatusColor(task.status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    if (blocked) ...[
                      const SizedBox(width: 10),
                      const Text(
                        "Blocked 🚫",
                        style: TextStyle(color: Colors.red),
                      ),
                    ]
                  ],
                ),
              ],
            ),
          ),

          // RIGHT SIDE ICONS
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _editTask(task),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteTask(task),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}