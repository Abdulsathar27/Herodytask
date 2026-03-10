import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task3/controller/auth_controller.dart';
import 'package:task3/views/screens/splash/widget/splash_view.dart';
import '../home/home_screen.dart';
import '../login/login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<AuthProvider, AuthStatus>(
      selector: (_, auth) => auth.status,
      builder: (_, status, __) {
        switch (status) {
          case AuthStatus.initial:
            return const SplashView();
          case AuthStatus.authenticated:
            return const HomeScreen();
          case AuthStatus.unauthenticated:
          case AuthStatus.loading:
            return const LoginScreen();
        }
      },
    );
  }
}

