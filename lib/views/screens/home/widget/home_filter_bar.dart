import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task3/controller/task_controller.dart';
import 'package:task3/views/widgets/stats_header.dart';

class HomeFilterBar extends StatelessWidget {
  const HomeFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Consumer<TaskProvider>(
        builder: (_, tasks, __) => FilterChips(
          selectedFilter: tasks.filter,
          onChanged: tasks.setFilter,
          allCount: tasks.totalCount,
          activeCount: tasks.activeCount,
          completedCount: tasks.completedCount,
        ),
      ),
    );
  }
}
