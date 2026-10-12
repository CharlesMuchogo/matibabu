import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matibabu/domain/entities/user.dart';
import 'package:matibabu/domain/repositories/user_repository.dart';
import 'package:matibabu/presentation/bloc/profile/profile_bloc.dart';
import 'package:matibabu/presentation/pages/profile_page.dart';
import 'package:matibabu/presentation/theme/app_theme.dart';
import 'package:matibabu/presentation/widgets/common.dart';

class EditProfilePage extends StatelessWidget {
  final User user;

  const EditProfilePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ProfileBloc(repository: context.read<UserRepository>()),
      child: _EditProfileView(user: user),
    );
  }
}

class _EditProfileView extends StatefulWidget {
  final User user;

  const _EditProfileView({required this.user});

  @override
  State<_EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<_EditProfileView> {
  late final _firstName = TextEditingController(text: widget.user.firstName);
  late final _lastName = TextEditingController(text: widget.user.lastName);
  late final _phone = TextEditingController(text: widget.user.phoneNumber);

  @override
  void dispose() {
    for (final controller in [_firstName, _lastName, _phone]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (_firstName.text.trim().isEmpty || _lastName.text.trim().isEmpty) {
      return showMessageDialog(
        context,
        "Missing details",
        "Enter your first and last name.",
      );
    }
    context.read<ProfileBloc>().add(
      ProfileUpdateSubmitted(
        ProfileUpdate(
          firstName: _firstName.text,
          lastName: _lastName.text,
          phoneNumber: _phone.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final saving = context.select(
      (ProfileBloc bloc) => bloc.state.isLoading(ProfileUpdateKind.details),
    );
    return ProfileUpdateListener(
      failureTitle: "Update failed",
      onSuccess: () {
        showSnack(context, "Your details were updated");
        Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Edit Details")),
        body: ListView(
          padding: AppSpacing.page,
          children: [
            AppTextField(
              controller: _firstName,
              label: "First name",
              icon: Icons.person_outline,
              keyboardType: TextInputType.name,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _lastName,
              label: "Last name",
              icon: Icons.person_outline,
              keyboardType: TextInputType.name,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _phone,
              label: "Phone number",
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: AppSpacing.lg),
            LoadingButton(
              label: "Save changes",
              loading: saving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
