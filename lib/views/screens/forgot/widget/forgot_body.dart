import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task3/config/app_theme.dart';
import 'package:task3/controller/auth_controller.dart';
import 'package:task3/views/screens/forgot/widget/success_view.dart';
import 'package:task3/views/widgets/app_button.dart';
import 'package:task3/views/widgets/app_text_field.dart';

class ForgotBody extends StatefulWidget {
  const ForgotBody({super.key});

  @override
  State<ForgotBody> createState() => _ForgotBodyState();
}

class _ForgotBodyState extends State<ForgotBody> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSend() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await context.read<AuthProvider>().sendPasswordReset(
      _emailCtrl.text.trim(),
    );

    if (success && mounted) {
      setState(() => _sent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_sent) {
      return SuccessView(
        email: _emailCtrl.text,
        onBack: () => Navigator.pop(context),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.lock_reset_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Enter your email and we'll send you a reset link.",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppTextField(
              controller: _emailCtrl,
              label: 'Email address',
              hint: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _onSend(),
              prefixIcon: const Icon(Icons.email_outlined, size: 18),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Email is required';
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 24),
            Selector<AuthProvider, bool>(
              selector: (_, auth) => auth.isLoading,
              builder: (_, isLoading, __) => AppButton(
                label: 'Send Reset Link',
                onPressed: _onSend,
                isLoading: isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
