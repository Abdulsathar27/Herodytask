
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task3/controller/auth_controller.dart';
import 'package:task3/controller/task_controller.dart';
import 'package:task3/models/task_model.dart';
import 'package:task3/views/screens/home/widget/home_app_bar.dart';
import 'package:task3/views/screens/home/widget/home_filter_bar.dart';
import 'package:task3/views/screens/home/widget/home_search_bar.dart';
import 'package:task3/views/screens/home/widget/home_stats_card.dart';
import 'package:task3/views/screens/home/widget/home_task_list.dart';
import 'package:task3/views/widgets/task_bottom_sheet.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<String?> _getToken(BuildContext context) =>
      context.read<AuthProvider>().getValidToken();

  String? _userId(BuildContext context) =>
      context.read<AuthProvider>().user?.uid;

  // ── Load ──────────────────────────────────────────────────────────────────
  Future<void> _loadTasks(BuildContext context) async {
    final token = await _getToken(context);
    final uid = _userId(context);
    if (token == null || uid == null) return;
    if (context.mounted) {
      await context.read<TaskProvider>().fetchTasks(uid, token);
    }
  }

  // ── Add ───────────────────────────────────────────────────────────────────
  Future<bool> _addTask(
    BuildContext context, {
    required String title,
    required String description,
    required TaskPriority priority,
    required TaskCategory category,
    DateTime? dueDate,
  }) async {
    final token = await _getToken(context);
    final uid = _userId(context);
    if (token == null || uid == null) return false;
    return context.read<TaskProvider>().addTask(
          userId: uid,
          token: token,
          title: title,
          description: description,
          priority: priority,
          category: category,
          dueDate: dueDate,
        );
  }

  // ── Edit ──────────────────────────────────────────────────────────────────
  Future<bool> _editTask(
    BuildContext context, {
    required TaskModel original,
    required String title,
    required String description,
    required TaskPriority priority,
    required TaskCategory category,
    DateTime? dueDate,
  }) async {
    final token = await _getToken(context);
    final uid = _userId(context);
    if (token == null || uid == null) return false;
    return context.read<TaskProvider>().updateTask(
          userId: uid,
          token: token,
          task: original.copyWith(
            title: title,
            description: description,
            priority: priority,
            category: category,
            dueDate: dueDate,
            clearDueDate: dueDate == null,
          ),
        );
  }

  
  Future<void> _toggleTask(BuildContext context, String taskId) async {
    final token = await _getToken(context);
    final uid = _userId(context);
    if (token == null || uid == null) return;
    if (context.mounted) {
      await context.read<TaskProvider>().toggleTask(uid, token, taskId);
    }
  }

  Future<void> _deleteTask(BuildContext context, String taskId) async {
    final token = await _getToken(context);
    final uid = _userId(context);
    if (token == null || uid == null) return;
    if (!context.mounted) return;

    final deleted =
        await context.read<TaskProvider>().deleteTask(uid, token, taskId);

    if (deleted && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Task deleted'),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }


  void _showAddSheet(BuildContext context) {
    TaskBottomSheet.show(
      context,
      onSave: ({
        required title,
        required description,
        required priority,
        required category,
        dueDate,
      }) =>
          _addTask(
        context,
        title: title,
        description: description,
        priority: priority,
        category: category,
        dueDate: dueDate,
      ),
    );
  }

  void _showEditSheet(BuildContext context, TaskModel task) {
    TaskBottomSheet.show(
      context,
      task: task,
      onSave: ({
        required title,
        required description,
        required priority,
        required category,
        dueDate,
      }) =>
          _editTask(
        context,
        original: task,
        title: title,
        description: description,
        priority: priority,
        category: category,
        dueDate: dueDate,
      ),
    );
  }
  @override
  Widget build(BuildContext context) {

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<TaskProvider>().status == TaskLoadStatus.initial) {
        _loadTasks(context);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const HomeAppBar(),
            const SliverToBoxAdapter(child: HomeStatsCard()),
            const SliverToBoxAdapter(child: HomeSearchBar()),
            const SliverToBoxAdapter(child: HomeFilterBar()),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            HomeTaskList(
              onToggle: (id) => _toggleTask(context, id),
              onEdit: (task) => _showEditSheet(context, task),
              onDelete: (id) => _deleteTask(context, id),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSheet(context),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }
}