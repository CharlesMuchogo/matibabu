import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:matibabu/GlobalComponents/authenticationservice.dart';
import 'package:matibabu/pages/updatedetails.dart';
import 'package:matibabu/theme/app_theme.dart';
import 'package:matibabu/widgets/common.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final String _uid = FirebaseAuth.instance.currentUser!.uid;
  bool _uploading = false;

  Future<void> _pickImage(String imageName, ImageSource source) async {
    final picture = await ImagePicker().pickImage(source: source);
    if (picture == null) return;

    final cropped = await ImageCropper().cropImage(
      sourcePath: picture.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 100,
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

    setState(() => _uploading = true);
    try {
      final upload = await FirebaseStorage.instance
          .ref()
          .child('images/{$imageName}')
          .putFile(File(cropped.path));
      final url = await upload.ref.getDownloadURL();
      await FirebaseFirestore.instance
          .collection("Patient")
          .doc(_uid)
          .update({"Profile Photo": url});
    } on FirebaseException catch (e) {
      if (mounted) {
        showMessageDialog(context, "Upload failed", e.message ?? e.code);
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _chooseImageSource(String imageName) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text("Choose from gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(imageName, ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text("Take a photo"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(imageName, ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final ok = await confirmDialog(
      context,
      title: "Log out?",
      confirmLabel: "Log out",
      destructive: true,
    );
    if (ok && mounted) await context.read<AuthenticationService>().signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection("Patient")
            .doc(_uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: ErrorView());
          final data = snapshot.data?.data();
          if (data == null) return const LoadingView();

          final scheme = Theme.of(context).colorScheme;
          final email = data["Email"] ?? "";

          return ListView(
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
                            onTap: () => _viewPhoto(data["Profile Photo"]),
                            child: Avatar(data["Profile Photo"], radius: 52),
                          ),
                          if (_uploading)
                            const Positioned.fill(
                              child: CircleAvatar(
                                backgroundColor: Colors.black38,
                                child: CircularProgressIndicator(
                                    color: Colors.white),
                              ),
                            ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Material(
                              color: scheme.primary,
                              shape: const CircleBorder(
                                  side: BorderSide(
                                      color: Colors.white, width: 3)),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: _uploading
                                    ? null
                                    : () => _chooseImageSource(email),
                                child: const Padding(
                                  padding: EdgeInsets.all(AppSpacing.sm),
                                  child: Icon(Icons.camera_alt_outlined,
                                      size: 18, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        "${data["First Name"] ?? ""} ${data["Last Name"] ?? ""}",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(email,
                          style: TextStyle(color: scheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ),
              SectionHeaderInline(
                "Personal information",
                action: TextButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UpdateDetails(
                        userId: _uid,
                        firstName: data["First Name"] ?? "",
                        lastName: data["Last Name"] ?? "",
                        phoneNumber: data["Phone Number"] ?? "",
                        address: data["Address"] ?? "",
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text("Edit"),
                ),
              ),
              Card(
                child: Column(
                  children: [
                    _infoTile(Icons.email_outlined, "Email", email),
                    const Divider(height: 1, indent: AppSpacing.md),
                    _infoTile(Icons.phone_outlined, "Phone number",
                        data["Phone Number"] ?? ""),
                    const Divider(height: 1, indent: AppSpacing.md),
                    _infoTile(Icons.location_on_outlined, "Address",
                        data["Address"] ?? ""),
                  ],
                ),
              ),
              const SectionHeaderInline("Account"),
              Card(
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  onTap: _logout,
                  leading: const Icon(Icons.logout_rounded,
                      color: AppColors.cancelled),
                  title: const Text("Log out",
                      style: TextStyle(color: AppColors.cancelled)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _viewPhoto(String? url) {
    if (url == null || url.isEmpty) return;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        clipBehavior: Clip.antiAlias,
        child: Image.network(url, fit: BoxFit.cover),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label, style: const TextStyle(fontSize: 13)),
      subtitle: Text(value.isEmpty ? "—" : value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
    );
  }
}
