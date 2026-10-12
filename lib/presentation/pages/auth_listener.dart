import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matibabu/presentation/bloc/auth/auth_bloc.dart';
import 'package:matibabu/presentation/widgets/common.dart';

class AuthFailureListener extends StatelessWidget {
  final String title;
  final Widget child;

  const AuthFailureListener({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          previous.action != current.action && current.action.isFailure,
      listener: (context, state) =>
          showMessageDialog(context, title, state.message),
      child: child,
    );
  }
}
