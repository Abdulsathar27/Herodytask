import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task3/controller/task_controller.dart';
import 'package:task3/views/widgets/stats_header.dart';

class HomeStatsCard extends StatelessWidget {
  const HomeStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Consumer<TaskProvider>(
        builder: (_, tasks, __) => StatsHeader(taskProvider: tasks),
      ),
    );
  }
}
