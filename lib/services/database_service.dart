// lib/services/database_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task_model.dart';
import '../config/app_theme.dart';

class DatabaseService {
  final String _base = AppConstants.firebaseDbUrl;

  String _tasksUrl(String userId, String token) =>
      '$_base/users/$userId/tasks.json?auth=$token';

  String _taskUrl(String userId, String taskId, String token) =>
      '$_base/users/$userId/tasks/$taskId.json?auth=$token';

  // ─── Fetch all tasks ─────────────────────────────────────────────────────
  Future<List<TaskModel>> fetchTasks(String userId, String token) async {
    final res = await http.get(Uri.parse(_tasksUrl(userId, token)));

    if (res.statusCode != 200) {
      throw Exception('Failed to fetch tasks (${res.statusCode})');
    }

    final data = json.decode(res.body);
    if (data == null) return [];

    final map = data as Map<String, dynamic>;
    final list = map.entries
        .map((e) => TaskModel.fromJson(e.value as Map<String, dynamic>, e.key))
        .toList();

    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  // ─── Add task — returns the Firebase-generated ID ─────────────────────────
  Future<String> addTaskGetId(
      String userId, String token, TaskModel task) async {
    final res = await http.post(
      Uri.parse(_tasksUrl(userId, token)),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(task.toJson()),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to add task (${res.statusCode})');
    }

    final data = json.decode(res.body) as Map<String, dynamic>;
    return data['name'] as String;
  }

  // ─── Update a task (PATCH merges fields) ─────────────────────────────────
  Future<void> updateTask(String userId, String token, TaskModel task) async {
    final res = await http.patch(
      Uri.parse(_taskUrl(userId, task.id, token)),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(task.toJson()),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to update task (${res.statusCode})');
    }
  }

  // ─── Toggle completion only ───────────────────────────────────────────────
  Future<void> toggleTaskCompletion(
      String userId, String token, String taskId, bool isCompleted) async {
    final res = await http.patch(
      Uri.parse(_taskUrl(userId, taskId, token)),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'isCompleted': isCompleted}),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to toggle task (${res.statusCode})');
    }
  }

  // ─── Delete a task ────────────────────────────────────────────────────────
  Future<void> deleteTask(
      String userId, String token, String taskId) async {
    final res = await http.delete(
      Uri.parse(_taskUrl(userId, taskId, token)),
    );

    // Firebase DELETE returns 200 with null body on success
    if (res.statusCode != 200) {
      throw Exception('Failed to delete task (${res.statusCode})');
    }
  }
}