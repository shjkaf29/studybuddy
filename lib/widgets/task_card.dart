import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import 'package:provider/provider.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggleComplete;

  const TaskCard({
    Key? key,
    required this.task,
    required this.onToggleComplete,
  }) : super(key: key);

  String _formatDateTime(DateTime dateTime) {
    final date = DateFormat('EEE, MMM d').format(dateTime);
    final time = DateFormat('h:mm a').format(dateTime);
    return '$date at $time';
  }

  Color _getTypeColor() {
    switch (task.type) {
      case 'Assignment':
        return Colors.blue;
      case 'Exam':
        return Colors.red;
      case 'Study Session':
        return Colors.green;
      case 'Project':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(task.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) async {
        try {
          await Provider.of<TaskService>(context, listen: false)
              .deleteTask(task.id, task.userEmail);
          
          if (!context.mounted) return;
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Task deleted')),
          );
        } catch (e) {
          if (!context.mounted) return;
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete task')),
          );
        }
      },
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Task'),
            content: const Text('Are you sure you want to delete this task?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: InkWell(
          onTap: () {
            // Show task details in a modal bottom sheet
            showModalBottomSheet(
              context: context,
              builder: (context) => _TaskDetailsSheet(task: task),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    Checkbox(
                      value: task.isCompleted,
                      onChanged: (_) => onToggleComplete(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  task.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      _formatDateTime(task.dueDate),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getTypeColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        task.type,
                        style: TextStyle(
                          color: _getTypeColor(),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TaskDetailsSheet extends StatelessWidget {
  final Task task;

  const _TaskDetailsSheet({required this.task});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            task.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            task.description,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Due Date'),
            subtitle: Text(DateFormat('EEEE, MMMM d, y').format(task.dueDate)),
          ),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: const Text('Due Time'),
            subtitle: Text(DateFormat('h:mm a').format(task.dueDate)),
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Task Type'),
            subtitle: Text(task.type),
          ),
          ListTile(
            leading: const Icon(Icons.check_circle),
            title: const Text('Status'),
            subtitle: Text(task.isCompleted ? 'Completed' : 'Pending'),
          ),
        ],
      ),
    );
  }
}