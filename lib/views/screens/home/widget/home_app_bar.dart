import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task3/config/app_theme.dart';
import 'package:task3/controller/auth_controller.dart';
import 'package:task3/views/screens/profile/profile_screen.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      automaticallyImplyLeading: false,
      titleSpacing: 20,
      title: Selector<AuthProvider, String>(
        selector: (_, auth) => auth.user?.firstName ?? 'there',
        builder: (_, name, __) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, $name 👋',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const Text(
              "Let's get things done",
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          ),
          child: Selector<AuthProvider, (String?, String?)>(
            selector: (_, auth) => (auth.user?.photoUrl, auth.user?.firstName),
            builder: (_, data, __) => Container(
              margin: const EdgeInsets.only(right: 16),
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                image: data.$1 != null
                    ? DecorationImage(
                        image: NetworkImage(data.$1!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: data.$1 == null
                  ? Center(
                      child: Text(
                        (data.$2 ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
