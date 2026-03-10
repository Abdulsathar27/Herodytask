
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../models/task_model.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final int index;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [
        FadeEffect(duration: 200.ms, delay: (index * 40).ms),
        SlideEffect(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
          duration: 200.ms,
          delay: (index * 40).ms,
        ),
      ],
      child: _TaskCardContent(
        task: task,
        onToggle: onToggle,
        onEdit: onEdit,
        onDelete: onDelete,
      ),
    );
  }
}

class _TaskCardContent extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TaskCardContent({
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  Color get _priorityColor {
    switch (task.priority) {
      case TaskPriority.high:
        return AppColors.priorityHigh;
      case TaskPriority.medium:
        return AppColors.priorityMedium;
      case TaskPriority.low:
        return AppColors.priorityLow;
    }
  }

  IconData get _categoryIcon {
    switch (task.category) {
      case TaskCategory.work:
        return Icons.work_outline_rounded;
      case TaskCategory.personal:
        return Icons.person_outline_rounded;
      case TaskCategory.shopping:
        return Icons.shopping_bag_outlined;
      case TaskCategory.health:
        return Icons.favorite_border_rounded;
      case TaskCategory.other:
        return Icons.label_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dismissible(
      key: ValueKey(task.id),
      background: _SwipeBackground(
          direction: DismissDirection.startToEnd,
          color: AppColors.success,
          icon: Icons.check_rounded),
      secondaryBackground: _SwipeBackground(
          direction: DismissDirection.endToStart,
          color: AppColors.error,
          icon: Icons.delete_outline_rounded),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onToggle();
          return false;
        } else {
          return await _confirmDelete(context);
        }
      },
      child: GestureDetector(
        onTap: onEdit,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Priority colour bar
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: task.isCompleted
                        ? AppColors.border
                        : _priorityColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _Checkbox(
                              isCompleted: task.isCompleted,
                              onToggle: onToggle,
                              color: _priorityColor,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.title,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: task.isCompleted
                                          ? AppColors.textHint
                                          : (isDark
                                              ? Colors.white
                                              : AppColors.textPrimary),
                                      decoration: task.isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                      decorationColor: AppColors.textHint,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (task.description.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      task.description,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: task.isCompleted
                                            ? AppColors.textHint
                                            : AppColors.textSecondary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            _CardMenu(
                                onEdit: onEdit, onDelete: onDelete),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _CardFooter(
                          task: task,
                          categoryIcon: _categoryIcon,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete task?'),
        content: const Text('This action cannot be undone.'),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _Checkbox extends StatelessWidget {
  final bool isCompleted;
  final VoidCallback onToggle;
  final Color color;

  const _Checkbox({
    required this.isCompleted,
    required this.onToggle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: isCompleted ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: isCompleted ? color : AppColors.border,
            width: 1.5,
          ),
        ),
        child: isCompleted
            ? const Icon(Icons.check_rounded,
                size: 16, color: Colors.white)
            : null,
      ),
    );
  }
}

class _CardFooter extends StatelessWidget {
  final TaskModel task;
  final IconData categoryIcon;

  const _CardFooter(
      {required this.task, required this.categoryIcon});

  @override
  Widget build(BuildContext context) {
    final isOverdue = task.dueDate != null &&
        task.dueDate!.isBefore(DateTime.now()) &&
        !task.isCompleted;

    return Row(
      children: [
        Icon(categoryIcon, size: 13, color: AppColors.textHint),
        const SizedBox(width: 4),
        Text(
          task.category.name[0].toUpperCase() +
              task.category.name.substring(1),
          style:
              const TextStyle(fontSize: 12, color: AppColors.textHint),
        ),
        const Spacer(),
        if (task.dueDate != null) ...[
          Icon(Icons.schedule_rounded,
              size: 13,
              color: isOverdue
                  ? AppColors.error
                  : AppColors.textHint),
          const SizedBox(width: 4),
          Text(
            DateFormat('MMM d').format(task.dueDate!),
            style: TextStyle(
              fontSize: 12,
              color: isOverdue
                  ? AppColors.error
                  : AppColors.textHint,
            ),
          ),
        ],
      ],
    );
  }
}

class _CardMenu extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CardMenu({required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      iconSize: 18,
      icon: const Icon(Icons.more_vert_rounded,
          color: AppColors.textHint),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      onSelected: (value) {
        if (value == 'edit') onEdit();
        if (value == 'delete') onDelete();
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined,
                  size: 16, color: AppColors.textSecondary),
              SizedBox(width: 8),
              Text('Edit'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded,
                  size: 16, color: AppColors.error),
              SizedBox(width: 8),
              Text('Delete',
                  style: TextStyle(color: AppColors.error)),
            ],
          ),
        ),
      ],
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  final DismissDirection direction;
  final Color color;
  final IconData icon;

  const _SwipeBackground({
    required this.direction,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isStart = direction == DismissDirection.startToEnd;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment:
          isStart ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Icon(icon, color: Colors.white, size: 24),
    );
  }
}