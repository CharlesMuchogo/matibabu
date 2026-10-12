import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:matibabu/domain/repositories/auth_repository.dart';
import 'package:matibabu/presentation/bloc/auth/auth_bloc.dart';
import 'package:matibabu/presentation/theme/app_theme.dart';
import 'package:matibabu/presentation/widgets/common.dart';

class SocialSignInButtons extends StatelessWidget {
  const SocialSignInButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthBloc>().state;
    final busy = state.action.isLoading;
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final appleBackground = dark ? Colors.white : Colors.black;
    final appleForeground = dark ? Colors.black : Colors.white;

    void signIn(SocialProvider provider) =>
        context.read<AuthBloc>().add(SocialLoginRequested(provider));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: busy ? null : () => signIn(SocialProvider.google),
          style: OutlinedButton.styleFrom(
            foregroundColor: scheme.onSurface,
            backgroundColor: Theme.of(context).cardTheme.color,
            side: BorderSide(color: scheme.outlineVariant),
          ),
          icon: state.isSubmitting(AuthMethod.google)
              ? const ButtonSpinner()
              : const FaIcon(
                  FontAwesomeIcons.google,
                  size: 18,
                  color: Color(0xFF4285F4),
                ),
          label: const Text("Continue with Google"),
        ),
        if (Platform.isIOS) ...[
          const SizedBox(height: AppSpacing.sm + 4),
          FilledButton.icon(
            onPressed: busy ? null : () => signIn(SocialProvider.apple),
            style: FilledButton.styleFrom(
              backgroundColor: appleBackground,
              foregroundColor: appleForeground,
              disabledBackgroundColor: appleBackground.withValues(alpha: 0.55),
            ),
            icon: state.isSubmitting(AuthMethod.apple)
                ? ButtonSpinner(color: appleForeground)
                : const FaIcon(FontAwesomeIcons.apple, size: 20),
            label: const Text("Continue with Apple"),
          ),
        ],
      ],
    );
  }
}
