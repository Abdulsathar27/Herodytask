
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task3/controller/task_controller.dart';
import 'package:task3/models/task_model.dart';
import 'package:task3/views/widgets/stats_header.dart';
import 'package:task3/views/widgets/task_card.dart';



class HomeTaskList extends StatelessWidget {
  final void Function(String taskId) onToggle;
  final void Function(TaskModel task) onEdit;
  final void Function(String taskId) onDelete;

  const HomeTaskList({
    super.key,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (_, tasks, __) {
        // Loading
        if (tasks.status == TaskLoadStatus.loading) {
          return const SliverFillRemaining(
            child: AppLoadingIndicator(),
          );
        }

        // Error
        if (tasks.status == TaskLoadStatus.error) {
          return SliverFillRemaining(
            child: EmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Something went wrong',
              subtitle: tasks.errorMessage ?? 'Please try again',
            ),
          );
        }

        final list = tasks.tasks;

        // Empty
        if (list.isEmpty) {
          return SliverFillRemaining(
            child: EmptyState(
              icon: Icons.check_circle_outline_rounded,
              title: tasks.searchQuery.isNotEmpty
                  ? 'No tasks found'
                  : 'No tasks yet',
              subtitle: tasks.searchQuery.isNotEmpty
                  ? 'Try a different search term'
                  : 'Tap + to add your first task',
            ),
          );
        }

        // Task list
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => TaskCard(
                key: ValueKey(list[i].id),
                task: list[i],
                index: i,
                onToggle: () => onToggle(list[i].id),
                onEdit: () => onEdit(list[i]),
                onDelete: () => onDelete(list[i].id),
              ),
              childCount: list.length,
            ),
          ),
        );
      },
    );
  }
}