import 'package:flutter/material.dart';
import 'package:task3/config/app_theme.dart';
import 'package:task3/views/widgets/app_button.dart';

class SuccessView extends StatelessWidget {
  final String email;
  final VoidCallback onBack;

  const SuccessView({required this.email, required this.onBack, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Color(0xFFECFDF5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mark_email_read_outlined,
              color: AppColors.success,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Check your inbox',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'We sent a password reset link to\n$email',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 32),
          AppButton(label: 'Back to Sign In', onPressed: onBack),
        ],
      ),
    );
  }
}
