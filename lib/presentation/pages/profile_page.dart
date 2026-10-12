import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:matibabu/domain/repositories/user_repository.dart';
import 'package:matibabu/presentation/bloc/auth/auth_bloc.dart';
import 'package:matibabu/presentation/bloc/profile/profile_bloc.dart';
import 'package:matibabu/presentation/bloc/status.dart';
import 'package:matibabu/presentation/pages/edit_profile_page.dart';
import 'package:matibabu/presentation/theme/app_theme.dart';
import 'package:matibabu/presentation/theme/theme_mode_selector.dart';
import 'package:matibabu/presentation/widgets/common.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ProfileBloc(repository: context.read<UserRepository>()),
      child: const _ProfileView(),
    );
  }
}

class ProfileUpdateListener extends StatelessWidget {
  final String failureTitle;
  final VoidCallback? onSuccess;
  final Widget child;

  const ProfileUpdateListener({
    super.key,
    required this.failureTitle,
    required this.child,
    this.onSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        final user = state.user;
        if (state.status == Status.loaded && user != null) {
          context.read<AuthBloc>().add(AuthUserChanged(user));
          onSuccess?.call();
        } else if (state.status.isFailure) {
          showMessageDialog(context, failureTitle, state.message);
        }
      },
      child: child,
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final bloc = context.read<ProfileBloc>();
    final picture = await ImagePicker().pickImage(source: source);
    if (picture == null) return;

    final cropped = await ImageCropper().cropImage(
      sourcePath: picture.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 90,
      maxHeight: 700,
      maxWidth: 700,
      compressFormat: ImageCompressFormat.jpg,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: "Crop photo",
          toolbarColor: AppColors.seed,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: true,
        ),
        IOSUiSettings(title: "Crop photo", aspectRatioLockEnabled: true),
      ],
    );
    if (cropped == null) return;
    bloc.add(ProfileUpdateSubmitted(ProfileUpdate(photoPath: cropped.path)));
  }

  void _chooseImageSource(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (source, icon, label) in [
                (
                  ImageSource.gallery,
                  Icons.photo_library_outlined,
                  "Choose from gallery",
                ),
                (
                  ImageSource.camera,
                  Icons.photo_camera_outlined,
                  "Take a photo",
                ),
              ])
                ListTile(
                  leading: Icon(icon),
                  title: Text(label),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickImage(context, source);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final ok = await confirmDialog(
      context,
      title: "Log out?",
      confirmLabel: "Log out",
      destructive: true,
    );
    if (ok && context.mounted) {
      context.read<AuthBloc>().add(const LogoutRequested());
    }
  }

  void _viewPhoto(BuildContext context, String url) {
    if (url.isEmpty) return;
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        clipBehavior: Clip.antiAlias,
        child: Image.network(url, fit: BoxFit.cover),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthBloc bloc) => bloc.state.user);
    final uploading = context.select(
      (ProfileBloc bloc) => bloc.state.isLoading(ProfileUpdateKind.photo),
    );
    if (user == null) return const Scaffold(body: LoadingView());
    final scheme = Theme.of(context).colorScheme;

    return ProfileUpdateListener(
      failureTitle: "Upload failed",
      child: Scaffold(
        appBar: AppBar(title: const Text("Profile")),
        body: ListView(
          padding: AppSpacing.page,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: () => _viewPhoto(context, user.profilePhoto),
                          child: Avatar(user.profilePhoto, radius: 52),
                        ),
                        if (uploading)
                          const Positioned.fill(
                            child: CircleAvatar(
                              backgroundColor: Colors.black38,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Material(
                            color: scheme.primary,
                            shape: CircleBorder(
                              side: BorderSide(
                                color: Theme.of(context).cardTheme.color!,
                                width: 3,
                              ),
                            ),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: uploading
                                  ? null
                                  : () => _chooseImageSource(context),
                              child: Padding(
                                padding: const EdgeInsets.all(AppSpacing.sm),
                                child: Icon(
                                  Icons.camera_alt_outlined,
                                  size: 18,
                                  color: scheme.onPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      user.fullName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      user.email,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
            SectionHeaderInline(
              "Personal information",
              action: TextButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => EditProfilePage(user: user),
                  ),
                ),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text("Edit"),
              ),
            ),
            Card(
              child: Column(
                children: [
                  DetailTile(Icons.email_outlined, "Email", user.email),
                  const Divider(height: 1, indent: AppSpacing.md),
                  DetailTile(
                    Icons.phone_outlined,
                    "Phone number",
                    user.phoneNumber,
                  ),
                  const Divider(height: 1, indent: AppSpacing.md),
                  DetailTile(
                    Icons.location_on_outlined,
                    "Address",
                    user.address,
                  ),
                ],
              ),
            ),
            const SectionHeaderInline("Appearance"),
            const Card(
              child: Padding(
                padding: AppSpacing.card,
                child: ThemeModeSelector(),
              ),
            ),
            const SectionHeaderInline("Account"),
            Card(
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                onTap: () => _logout(context),
                leading: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.cancelled,
                ),
                title: const Text(
                  "Log out",
                  style: TextStyle(color: AppColors.cancelled),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
