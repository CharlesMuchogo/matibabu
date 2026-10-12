import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matibabu/domain/repositories/auth_repository.dart';
import 'package:matibabu/presentation/bloc/password_reset/password_reset_bloc.dart';
import 'package:matibabu/presentation/theme/app_theme.dart';
import 'package:matibabu/presentation/widgets/common.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          PasswordResetBloc(repository: context.read<AuthRepository>()),
      child: const _ResetPasswordView(),
    );
  }
}

class _ResetPasswordView extends StatefulWidget {
  const _ResetPasswordView();

  @override
  State<_ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<_ResetPasswordView> {
  final _email = TextEditingController();
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  @override
  void dispose() {
    for (final controller in [_email, _code, _password, _confirmPassword]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _requestCode() {
    if (_email.text.trim().isEmpty) {
      return showMessageDialog(context, "Missing email", "Enter your email.");
    }
    context.read<PasswordResetBloc>().add(
      PasswordResetCodeRequested(_email.text),
    );
  }

  void _reset() {
    if (_code.text.trim().isEmpty || _password.text.isEmpty) {
      return showMessageDialog(
        context,
        "Missing details",
        "Enter the code from your email and a new password.",
      );
    }
    if (_password.text != _confirmPassword.text) {
      return showMessageDialog(
        context,
        "Check your password",
        "Passwords do not match.",
      );
    }
    context.read<PasswordResetBloc>().add(
      PasswordResetSubmitted(code: _code.text, newPassword: _password.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PasswordResetBloc, PasswordResetState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status.isFailure) {
          showMessageDialog(context, "Couldn't reset password", state.message);
        } else if (state.step == PasswordResetStep.done) {
          showSnack(context, "Password reset. Sign in with your new password.");
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        final loading = state.status.isLoading;
        final codeStep = state.step != PasswordResetStep.email;
        return Scaffold(
          appBar: AppBar(),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            children: [
              AuthHeader(
                title: "Reset password",
                subtitle: codeStep
                    ? "We sent a 6-digit code to ${state.email}. If you "
                          "don't see it, check your spam folder."
                    : "Enter your email and we'll send you a reset code.",
              ),
              const SizedBox(height: AppSpacing.xl),
              if (!codeStep) ...[
                AppTextField(
                  controller: _email,
                  label: "Email",
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  onSubmitted: (_) => _requestCode(),
                ),
                const SizedBox(height: AppSpacing.lg),
                LoadingButton(
                  label: "Send reset code",
                  loading: loading,
                  onPressed: _requestCode,
                ),
              ] else ...[
                AppTextField(
                  controller: _code,
                  label: "Reset code",
                  icon: Icons.pin_outlined,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _password,
                  label: "New password",
                  icon: Icons.lock_outline,
                  obscure: true,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _confirmPassword,
                  label: "Confirm new password",
                  icon: Icons.lock_outline,
                  obscure: true,
                  onSubmitted: (_) => _reset(),
                ),
                const SizedBox(height: AppSpacing.lg),
                LoadingButton(
                  label: "Reset password",
                  loading: loading,
                  onPressed: _reset,
                ),
                TextButton(
                  onPressed: loading ? null : _requestCode,
                  child: const Text("Send a new code"),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
