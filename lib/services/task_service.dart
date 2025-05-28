import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class TaskService {
  static const String _tasksKey = 'all_tasks';

  Future<List<Task>> getTasks({required String userEmail}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getStringList(_tasksKey) ?? [];
      
      return tasksJson
          .map((json) => Task.fromMap(jsonDecode(json)))
          .where((task) => task.userEmail == userEmail) // Filter by user email
          .toList()
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    } catch (e) {
      print('Error getting tasks: $e');
      return [];
    }
  }

  Future<bool> addTask(Task task) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> tasks = prefs.getStringList(_tasksKey) ?? [];
      tasks.add(jsonEncode(task.toMap()));
      return await prefs.setStringList(_tasksKey, tasks);
    } catch (e) {
      print('Error adding task: $e');
      return false;
    }
  }

  Future<bool> updateTask(Task task) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> tasks = prefs.getStringList(_tasksKey) ?? [];
      final index = tasks.indexWhere((t) {
        final taskMap = jsonDecode(t);
        return taskMap['id'] == task.id && taskMap['userEmail'] == task.userEmail;
      });
      
      if (index != -1) {
        tasks[index] = jsonEncode(task.toMap());
        return await prefs.setStringList(_tasksKey, tasks);
      }
      return false;
    } catch (e) {
      print('Error updating task: $e');
      return false;
    }
  }

  Future<bool> deleteTask(String taskId, String userEmail) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> tasks = prefs.getStringList(_tasksKey) ?? [];
      final initialLength = tasks.length;
      
      tasks.removeWhere((t) {
        final taskMap = jsonDecode(t);
        return taskMap['id'] == taskId && taskMap['userEmail'] == userEmail;
      });
      
      if (tasks.length != initialLength) {
        return await prefs.setStringList(_tasksKey, tasks);
      }
      return false;
    } catch (e) {
      print('Error deleting task: $e');
      return false;
    }
  }

  Future<Map<String, int>> getTaskStats(String userEmail) async {
    try {
      final tasks = await getTasks(userEmail: userEmail);
      final completedTasks = tasks.where((task) => task.isCompleted).length;
      
      return {
        'total': tasks.length,
        'completed': completedTasks,
        'pending': tasks.length - completedTasks,
      };
    } catch (e) {
      print('Error getting task stats: $e');
      return {
        'total': 0,
        'completed': 0,
        'pending': 0,
      };
    }
  }
}