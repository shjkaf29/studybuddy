import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/task.dart';

class TaskService extends ChangeNotifier {
  final List<Task> _tasks = [];

  Future<List<Task>> getTasks({required String userEmail}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getString('tasks_$userEmail');
      if (tasksJson != null) {
        final List<dynamic> decodedList = jsonDecode(tasksJson);
        _tasks.clear();
        _tasks.addAll(decodedList.map((item) => Task.fromMap(item)));
        return _tasks.where((task) => task.userEmail == userEmail).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error loading tasks: $e');
      return [];
    }
  }

  Future<void> addTask(Task task) async {
    _tasks.add(task);
    await _saveTasks(task.userEmail);
    notifyListeners();
  }

  Future<void> toggleTaskComplete(String taskId) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final task = _tasks[index];
      _tasks[index] = task.copyWith(
        isCompleted: !task.isCompleted,
        completedAt: !task.isCompleted ? DateTime.now() : null,
      );
      await _saveTasks(_tasks[index].userEmail);
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    final task = _tasks.firstWhere((t) => t.id == taskId);
    _tasks.removeWhere((t) => t.id == taskId);
    await _saveTasks(task.userEmail);
    notifyListeners();
  }

  Future<void> updateTask(Task updatedTask) async {
    final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      await _saveTasks(updatedTask.userEmail);
      notifyListeners();
    }
  }

  Future<Map<String, int>> getTaskStats(String userEmail) async {
    final tasks = await getTasks(userEmail: userEmail);
    final now = DateTime.now();
    
    return {
      'total': tasks.length,
      'completed': tasks.where((task) => task.isCompleted).length,
      'pending': tasks.where((task) => !task.isCompleted).length,
      'upcoming': tasks.where((task) => 
        !task.isCompleted && 
        task.dueDate.isAfter(now)
      ).length,
      'overdue': tasks.where((task) => 
        !task.isCompleted && 
        task.dueDate.isBefore(now)
      ).length,
      'today': tasks.where((task) =>
        task.dueDate.year == now.year &&
        task.dueDate.month == now.month &&
        task.dueDate.day == now.day
      ).length,
    };
  }

  Future<Map<String, List<Task>>> getTasksByType(String userEmail) async {
    final tasks = await getTasks(userEmail: userEmail);
    final Map<String, List<Task>> tasksByType = {};
    
    for (var task in tasks) {
      if (!tasksByType.containsKey(task.type)) {
        tasksByType[task.type] = [];
      }
      tasksByType[task.type]!.add(task);
    }
    
    return tasksByType;
  }

  Future<List<Task>> getTasksByDate(String userEmail, DateTime date) async {
    final tasks = await getTasks(userEmail: userEmail);
    return tasks.where((task) =>
      task.dueDate.year == date.year &&
      task.dueDate.month == date.month &&
      task.dueDate.day == date.day
    ).toList();
  }

  Future<void> _saveTasks(String userEmail) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userTasks = _tasks.where((t) => t.userEmail == userEmail).toList();
      await prefs.setString(
        'tasks_$userEmail',
        jsonEncode(userTasks.map((t) => t.toMap()).toList()),
      );
    } catch (e) {
      debugPrint('Error saving tasks: $e');
    }
  }

  Future<void> clearCompletedTasks(String userEmail) async {
    _tasks.removeWhere((task) => 
      task.userEmail == userEmail && task.isCompleted
    );
    await _saveTasks(userEmail);
    notifyListeners();
  }

  double getCompletionRate(String userEmail) {
    final userTasks = _tasks.where((t) => t.userEmail == userEmail).toList();
    if (userTasks.isEmpty) return 0.0;
    
    final completed = userTasks.where((t) => t.isCompleted).length;
    return completed / userTasks.length;
  }
}