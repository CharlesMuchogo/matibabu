import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:matibabu/pages/login.dart';
import 'package:provider/provider.dart';

import '../pages/navbar.dart';

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();
      
    if (firebaseUser != null) {
      return BottomBarScreen();
    } else {
      return login();
    }
  }
}
