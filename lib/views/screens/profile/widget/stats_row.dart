import 'package:flutter/material.dart';
import 'package:task3/config/app_theme.dart';
import 'package:task3/views/screens/profile/widget/stat_card.dart';

class StatsRow extends StatelessWidget {
  final int total;
  final int completed;
  final int active;

  const StatsRow({
    required this.total,
    required this.completed,
    required this.active,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        StatCard(value: '$total', label: 'Total'),
        const SizedBox(width: 12),
        StatCard(
            value: '$completed',
            label: 'Done',
            color: AppColors.success),
        const SizedBox(width: 12),
        StatCard(
            value: '$active',
            label: 'Active',
            color: AppColors.warning),
      ],
    );
  }
}