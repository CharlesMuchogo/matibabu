import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:matibabu/pages/login.dart';
import 'package:provider/provider.dart';

import '../pages/navbar.dart';

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();

    if (firebaseUser != null) {
      return const BottomBarScreen();
    } else {
      return const LoginPage();
    }
  }
}
