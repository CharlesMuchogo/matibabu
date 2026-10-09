import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:matibabu/theme/app_theme.dart';
import 'package:matibabu/widgets/common.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final _email = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _reset() async {
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _email.text.trim());
      if (!mounted) return;
      showMessageDialog(
        context,
        "Check your email",
        "We've sent a password reset link. If you don't see it in your inbox, "
            "check your spam folder.",
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      showMessageDialog(context, "Couldn't send email", e.message ?? e.code);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
        children: [
          const AuthHeader(
            title: "Reset password",
            subtitle: "Enter your email and we'll send you a reset link.",
          ),
          const SizedBox(height: AppSpacing.xl),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            onSubmitted: (_) => _reset(),
            decoration: const InputDecoration(
              labelText: "Email",
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          LoadingButton(
              label: "Send reset link", loading: _loading, onPressed: _reset),
        ],
      ),
    );
  }
}
