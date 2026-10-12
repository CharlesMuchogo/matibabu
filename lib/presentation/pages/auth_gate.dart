import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matibabu/presentation/bloc/auth/auth_bloc.dart';
import 'package:matibabu/presentation/navigation/chat_router.dart';
import 'package:matibabu/presentation/pages/home_shell.dart';
import 'package:matibabu/presentation/pages/login_page.dart';
import 'package:matibabu/presentation/widgets/common.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        ChatRouter.navigatorKey.currentState?.popUntil(
          (route) => route.isFirst,
        );
        if (state.message.isNotEmpty &&
            state.status == AuthStatus.unauthenticated) {
          showSnack(context, state.message);
        }
      },
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          (previous.user == null) != (current.user == null) ||
          previous.action != current.action,
      builder: (context, state) => switch (state.status) {
        AuthStatus.unknown => const Scaffold(body: LoadingView()),
        AuthStatus.unauthenticated => const LoginPage(),
        AuthStatus.authenticated when state.user != null => const HomeShell(),
        AuthStatus.authenticated => Scaffold(
          body: Center(
            child: state.action.isFailure
                ? ErrorView(
                    message: state.message,
                    onRetry: () =>
                        context.read<AuthBloc>().add(const AuthStarted()),
                  )
                : const LoadingView(),
          ),
        ),
      },
    );
  }
}
