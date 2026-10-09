import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:matibabu/GlobalComponents/authenticationservice.dart';
import 'package:matibabu/GlobalComponents/autheticationwrapper.dart';
import 'package:matibabu/theme/app_theme.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        Provider<AuthenticationService>(
          create: (_) => AuthenticationService(FirebaseAuth.instance),
        ),
        StreamProvider<User?>(
          create: (context) =>
              context.read<AuthenticationService>().authstateChanges,
          initialData: null,
        )
      ],
      child: MaterialApp(
        title: "Matibabu",
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const AuthenticationWrapper(),
      ),
    ),
  );
}
