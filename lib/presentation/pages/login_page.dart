import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matibabu/presentation/bloc/auth/auth_bloc.dart';
import 'package:matibabu/presentation/pages/auth_listener.dart';
import 'package:matibabu/presentation/pages/reset_password_page.dart';
import 'package:matibabu/presentation/pages/signup_page.dart';
import 'package:matibabu/presentation/theme/app_theme.dart';
import 'package:matibabu/presentation/widgets/common.dart';
import 'package:matibabu/presentation/widgets/social_buttons.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _login() => context.read<AuthBloc>().add(
    LoginRequested(email: _email.text, password: _password.text),
  );

  @override
  Widget build(BuildContext context) {
    final submitting = context.select(
      (AuthBloc bloc) => bloc.state.isSubmitting(AuthMethod.email),
    );
    return AuthFailureListener(
      title: "Couldn't sign in",
      child: Scaffold(
        body: SafeArea(
          child: AutofillGroup(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              children: [
                const AuthHeader(
                  title: "Welcome back",
                  subtitle: "Sign in to manage your appointments.",
                ),
                const SizedBox(height: AppSpacing.xl),
                AppTextField(
                  controller: _email,
                  label: "Email",
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _password,
                  label: "Password",
                  icon: Icons.lock_outline,
                  obscure: _obscure,
                  autofillHints: const [AutofillHints.password],
                  onSubmitted: (_) => _login(),
                  suffix: IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const ResetPasswordPage(),
                      ),
                    ),
                    child: const Text("Forgot password?"),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                LoadingButton(
                  label: "Sign in",
                  loading: submitting,
                  onPressed: _login,
                ),
                const OrDivider(),
                const SocialSignInButtons(),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const SignupPage(),
                        ),
                      ),
                      child: const Text("Sign up"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
