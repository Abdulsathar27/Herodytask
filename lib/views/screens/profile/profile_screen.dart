import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task3/controller/auth_controller.dart';
import 'package:task3/controller/task_controller.dart';
import 'package:task3/views/screens/profile/widget/avatar_section.dart';
import 'package:task3/views/screens/profile/widget/profile_tile.dart';
import 'package:task3/views/screens/profile/widget/stats_row.dart';
import '../../widgets/app_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const SafeArea(child: _ProfileBody()),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody();

  Future<void> _onSignOut(BuildContext context) async {
    context.read<TaskProvider>().clearTasks();
    await context.read<AuthProvider>().signOut();
    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Avatar
          Selector<AuthProvider, (String?, String?, String?)>(
            selector: (_, auth) => (
              auth.user?.firstName,
              auth.user?.email,
              auth.user?.photoUrl,
            ),
            builder: (_, data, __) => AvatarSection(
              name: data.$1 ?? 'User',
              email: data.$2 ?? '',
              photoUrl: data.$3,
            ),
          ),
          const SizedBox(height: 24),

          // Stats row
          Selector<TaskProvider, (int, int, int)>(
            selector: (_, tasks) => (
              tasks.totalCount,
              tasks.completedCount,
              tasks.activeCount,
            ),
            builder: (_, data, __) => StatsRow(
              total: data.$1,
              completed: data.$2,
              active: data.$3,
            ),
          ),
          const SizedBox(height: 24),

          // Info tiles
          Selector<AuthProvider, (String?, String?)>(
            selector: (_, auth) =>
                (auth.user?.displayName, auth.user?.email),
            builder: (_, data, __) => Column(
              children: [
                ProfileTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Display name',
                  value: data.$1 ?? 'Not set',
                ),
                ProfileTile(
                  icon: Icons.email_outlined,
                  title: 'Email',
                  value: data.$2 ?? '',
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          AppButton(
            label: 'Sign Out',
            type: ButtonType.outline,
            icon: Icons.logout_rounded,
            onPressed: () => _onSignOut(context),
          ),
        ],
      ),
    );
  }
}






