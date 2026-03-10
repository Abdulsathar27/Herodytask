// lib/providers/task_provider.dart
import '../models/task_model.dart';
import '../services/database_service.dart';
import 'package:flutter/foundation.dart';

// ─── Golden Rule ──────────────────────────────────────────────────────────────
// Provider ONLY holds state + talks to the Service layer.
// It NEVER imports: BuildContext, SnackBar, Navigator,
//                   TaskBottomSheet, AuthProvider, or any widget.
// The UI (screens/widgets) calls provider methods and shows SnackBars itself.
// ─────────────────────────────────────────────────────────────────────────────

enum TaskLoadStatus { initial, loading, loaded, error }

enum TaskFilter { all, active, completed }

class TaskProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  TaskLoadStatus _status = TaskLoadStatus.initial;
  List<TaskModel> _tasks = [];
  String? _errorMessage;
  TaskFilter _filter = TaskFilter.all;
  TaskCategory? _categoryFilter;
  String _searchQuery = '';

  // ─── Getters ──────────────────────────────────────────────────────────────
  TaskLoadStatus get status => _status;
  String? get errorMessage => _errorMessage;
  TaskFilter get filter => _filter;
  TaskCategory? get categoryFilter => _categoryFilter;
  String get searchQuery => _searchQuery;

  int get totalCount => _tasks.length;
  int get completedCount => _tasks.where((t) => t.isCompleted).length;
  int get activeCount => _tasks.where((t) => !t.isCompleted).length;
  double get completionRate =>
      _tasks.isEmpty ? 0.0 : completedCount / _tasks.length;

  // Filtered + searched list for the UI
  List<TaskModel> get tasks {
    List<TaskModel> result = List.from(_tasks);

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where((t) =>
              t.title.toLowerCase().contains(q) ||
              t.description.toLowerCase().contains(q))
          .toList();
    }

    switch (_filter) {
      case TaskFilter.active:
        result = result.where((t) => !t.isCompleted).toList();
        break;
      case TaskFilter.completed:
        result = result.where((t) => t.isCompleted).toList();
        break;
      case TaskFilter.all:
        break;
    }

    if (_categoryFilter != null) {
      result = result.where((t) => t.category == _categoryFilter).toList();
    }

    return result;
  }

  // ─── Fetch ────────────────────────────────────────────────────────────────
  Future<void> fetchTasks(String userId, String token) async {
    _status = TaskLoadStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _tasks = await _db.fetchTasks(userId, token);
      _status = TaskLoadStatus.loaded;
    } catch (_) {
      _status = TaskLoadStatus.error;
      _errorMessage = 'Failed to load tasks. Check your connection.';
    }
    notifyListeners();
  }

  // ─── Add ──────────────────────────────────────────────────────────────────
  Future<bool> addTask({
    required String userId,
    required String token,
    required String title,
    String description = '',
    TaskPriority priority = TaskPriority.medium,
    TaskCategory category = TaskCategory.personal,
    DateTime? dueDate,
  }) async {
    try {
      final placeholder = TaskModel(
        id: 'temp',
        userId: userId,
        title: title,
        description: description,
        priority: priority,
        category: category,
        dueDate: dueDate,
        createdAt: DateTime.now(),
      );
      final newId = await _db.addTaskGetId(userId, token, placeholder);
      _tasks.insert(
        0,
        TaskModel(
          id: newId,
          userId: userId,
          title: title,
          description: description,
          priority: priority,
          category: category,
          dueDate: dueDate,
          createdAt: DateTime.now(),
        ),
      );
      notifyListeners();
      return true;
    } catch (_) {
      _errorMessage = 'Failed to add task. Please try again.';
      notifyListeners();
      return false;
    }
  }

  // ─── Update ───────────────────────────────────────────────────────────────
  Future<bool> updateTask({
    required String userId,
    required String token,
    required TaskModel task,
  }) async {
    try {
      await _db.updateTask(userId, token, task);
      final i = _tasks.indexWhere((t) => t.id == task.id);
      if (i != -1) {
        _tasks[i] = task;
        notifyListeners();
      }
      return true;
    } catch (_) {
      _errorMessage = 'Failed to update task. Please try again.';
      notifyListeners();
      return false;
    }
  }

  // ─── Toggle (optimistic) ──────────────────────────────────────────────────
  Future<void> toggleTask(String userId, String token, String taskId) async {
    final i = _tasks.indexWhere((t) => t.id == taskId);
    if (i == -1) return;
    final newValue = !_tasks[i].isCompleted;
    _tasks[i].isCompleted = newValue;
    notifyListeners();
    try {
      await _db.toggleTaskCompletion(userId, token, taskId, newValue);
    } catch (_) {
      _tasks[i].isCompleted = !newValue; // revert on failure
      notifyListeners();
    }
  }

  // ─── Delete (optimistic) ──────────────────────────────────────────────────
  Future<bool> deleteTask(String userId, String token, String taskId) async {
    final i = _tasks.indexWhere((t) => t.id == taskId);
    if (i == -1) return false;
    final removed = _tasks[i];
    _tasks.removeAt(i);
    notifyListeners();
    try {
      await _db.deleteTask(userId, token, taskId);
      return true;
    } catch (_) {
      _tasks.insert(i, removed); // revert on failure
      notifyListeners();
      return false;
    }
  }

  // ─── Filters ──────────────────────────────────────────────────────────────
  void setFilter(TaskFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  void setCategoryFilter(TaskCategory? category) {
    _categoryFilter = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // ─── Clear on sign-out ────────────────────────────────────────────────────
  void clearTasks() {
    _tasks = [];
    _status = TaskLoadStatus.initial;
    _errorMessage = null;
    _searchQuery = '';
    _filter = TaskFilter.all;
    _categoryFilter = null;
    notifyListeners();
  }
}