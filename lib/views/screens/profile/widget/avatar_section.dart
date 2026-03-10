import 'package:flutter/material.dart';
import 'package:task3/config/app_theme.dart';

class AvatarSection extends StatelessWidget {
  final String name;
  final String email;
  final String? photoUrl;

  const AvatarSection({
    required this.name,
    required this.email,
    this.photoUrl,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            image: photoUrl != null
                ? DecorationImage(
                    image: NetworkImage(photoUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: photoUrl == null
              ? Center(
                  child: Text(
                    name[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              : null,
        ),
        const SizedBox(height: 12),
        Text(
          name,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: const TextStyle(
              fontSize: 14, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}