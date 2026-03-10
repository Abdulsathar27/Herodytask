import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task3/config/app_theme.dart';
import 'package:task3/controller/auth_controller.dart';
import 'package:task3/views/widgets/app_button.dart';
import 'package:task3/views/widgets/app_text_field.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});
  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.signUp(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      displayName: _nameCtrl.text.trim(),
    );
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(auth.errorMessage ?? 'Registration failed'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Create your account',
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'Start organizing your tasks today',
              style:
                  TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 28),
            AppTextField(
              controller: _nameCtrl,
              label: 'Full name',
              hint: 'John Doe',
              textInputAction: TextInputAction.next,
              prefixIcon: const Icon(
                  Icons.person_outline_rounded, size: 18),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Name is required'
                  : null,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _emailCtrl,
              label: 'Email',
              hint: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              prefixIcon:
                  const Icon(Icons.email_outlined, size: 18),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Email is required';
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 12),
            AppPasswordField(
              controller: _passwordCtrl,
              label: 'Password',
              textInputAction: TextInputAction.next,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password is required';
                if (v.length < 6) return 'Password must be 6+ characters';
                return null;
              },
            ),
            const SizedBox(height: 12),
            AppPasswordField(
              controller: _confirmCtrl,
              label: 'Confirm password',
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _onSignUp(),
              validator: (v) => v != _passwordCtrl.text
                  ? 'Passwords do not match'
                  : null,
            ),
            const SizedBox(height: 28),
            Selector<AuthProvider, bool>(
              selector: (_, auth) => auth.isLoading,
              builder: (_, isLoading, __) => AppButton(
                label: 'Create Account',
                onPressed: _onSignUp,
                isLoading: isLoading,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Already have an account? ',
                  style:
                      TextStyle(color: AppColors.textSecondary),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    'Sign in',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}