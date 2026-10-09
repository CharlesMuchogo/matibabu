import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:matibabu/GlobalComponents/authenticationservice.dart';
import 'package:matibabu/GlobalComponents/restapi.dart';
import 'package:matibabu/theme/app_theme.dart';
import 'package:matibabu/widgets/common.dart';
import 'package:provider/provider.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    for (final c in [
      _firstName,
      _lastName,
      _email,
      _phone,
      _address,
      _password,
      _confirmPassword
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _signUp() async {
    final fields = [
      _firstName,
      _lastName,
      _email,
      _phone,
      _address,
      _password,
      _confirmPassword
    ];
    if (fields.any((c) => c.text.trim().isEmpty)) {
      showMessageDialog(context, "Missing details", "Fill in all the details.");
      return;
    }
    if (_password.text != _confirmPassword.text) {
      showMessageDialog(
          context, "Check your password", "Passwords do not match.");
      return;
    }

    setState(() => _loading = true);
    final navigator = Navigator.of(context);
    try {
      await context.read<AuthenticationService>().signUp(
            email: _email.text.toLowerCase().trim(),
            password: _password.text.trim(),
          );
      await RestApi().createData(
        _firstName.text.trim(),
        _lastName.text.trim(),
        _email.text.trim(),
        _phone.text.trim(),
        _address.text.trim(),
      );
      navigator.pop();
    } on FirebaseException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      showMessageDialog(context, "Couldn't sign up", e.message ?? e.code);
    }
  }

  Widget _field(TextEditingController controller, String label, IconData icon,
      {TextInputType? keyboard, bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        obscureText: obscure,
        textInputAction: TextInputAction.next,
        textCapitalization: keyboard == TextInputType.name
            ? TextCapitalization.words
            : TextCapitalization.none,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      ),
    );
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
            title: "Create account",
            subtitle: "Book and track appointments with top specialists.",
          ),
          const SizedBox(height: AppSpacing.xl),
          const GoogleSignInButton(),
          const OrDivider(),
          Row(
            children: [
              Expanded(
                  child: _field(_firstName, "First name", Icons.person_outline,
                      keyboard: TextInputType.name)),
              const SizedBox(width: AppSpacing.sm + 4),
              Expanded(
                  child: _field(_lastName, "Last name", Icons.person_outline,
                      keyboard: TextInputType.name)),
            ],
          ),
          _field(_email, "Email", Icons.email_outlined,
              keyboard: TextInputType.emailAddress),
          _field(_phone, "Phone number", Icons.phone_outlined,
              keyboard: TextInputType.phone),
          _field(_address, "Address", Icons.location_on_outlined,
              keyboard: TextInputType.streetAddress),
          _field(_password, "Password", Icons.lock_outline, obscure: true),
          _field(_confirmPassword, "Confirm password", Icons.lock_outline,
              obscure: true),
          const SizedBox(height: AppSpacing.sm),
          LoadingButton(
              label: "Create account", loading: _loading, onPressed: _signUp),
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
    );
  }
}
