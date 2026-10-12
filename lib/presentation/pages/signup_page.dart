import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matibabu/domain/repositories/auth_repository.dart';
import 'package:matibabu/presentation/bloc/auth/auth_bloc.dart';
import 'package:matibabu/presentation/pages/auth_listener.dart';
import 'package:matibabu/presentation/theme/app_theme.dart';
import 'package:matibabu/presentation/widgets/common.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  List<TextEditingController> get _fields => [
    _firstName,
    _lastName,
    _email,
    _phone,
    _password,
    _confirmPassword,
  ];

  @override
  void dispose() {
    for (final controller in _fields) {
      controller.dispose();
    }
    super.dispose();
  }

  void _signUp() {
    if (_fields.any((c) => c.text.trim().isEmpty)) {
      return showMessageDialog(
        context,
        "Missing details",
        "Fill in all the details.",
      );
    }
    if (_password.text != _confirmPassword.text) {
      return showMessageDialog(
        context,
        "Check your password",
        "Passwords do not match.",
      );
    }
    context.read<AuthBloc>().add(
      RegisterRequested(
        Registration(
          firstName: _firstName.text,
          lastName: _lastName.text,
          email: _email.text,
          phoneNumber: _phone.text,
          password: _password.text,
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboard,
    bool obscure = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.md),
    child: AppTextField(
      controller: controller,
      label: label,
      icon: icon,
      keyboardType: keyboard,
      obscure: obscure,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final submitting = context.select(
      (AuthBloc bloc) => bloc.state.isSubmitting(AuthMethod.email),
    );
    return AuthFailureListener(
      title: "Couldn't sign up",
      child: Scaffold(
        appBar: AppBar(),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          children: [
            const AuthHeader(
              title: "Create account",
              subtitle: "Book and track appointments with top specialists.",
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: _field(
                    _firstName,
                    "First name",
                    Icons.person_outline,
                    keyboard: TextInputType.name,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm + 4),
                Expanded(
                  child: _field(
                    _lastName,
                    "Last name",
                    Icons.person_outline,
                    keyboard: TextInputType.name,
                  ),
                ),
              ],
            ),
            _field(
              _email,
              "Email",
              Icons.email_outlined,
              keyboard: TextInputType.emailAddress,
            ),
            _field(
              _phone,
              "Phone number",
              Icons.phone_outlined,
              keyboard: TextInputType.phone,
            ),
            _field(_password, "Password", Icons.lock_outline, obscure: true),
            _field(
              _confirmPassword,
              "Confirm password",
              Icons.lock_outline,
              obscure: true,
            ),
            const SizedBox(height: AppSpacing.sm),
            LoadingButton(
              label: "Create account",
              loading: submitting,
              onPressed: _signUp,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account?"),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Sign in"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
