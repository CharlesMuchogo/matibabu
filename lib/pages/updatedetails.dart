import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:matibabu/theme/app_theme.dart';
import 'package:matibabu/widgets/common.dart';

class UpdateDetails extends StatefulWidget {
  final String userId;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String address;

  const UpdateDetails({
    super.key,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.address,
  });

  @override
  State<UpdateDetails> createState() => _UpdateDetailsState();
}

class _UpdateDetailsState extends State<UpdateDetails> {
  late final _firstName = TextEditingController(text: widget.firstName);
  late final _lastName = TextEditingController(text: widget.lastName);
  late final _address = TextEditingController(text: widget.address);
  late final _phone = TextEditingController(text: widget.phoneNumber);
  bool _saving = false;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _address.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance
          .collection("Patient")
          .doc(widget.userId)
          .update({
        "First Name": _firstName.text.trim(),
        "Last Name": _lastName.text.trim(),
        "Address": _address.text.trim(),
        "Phone Number": _phone.text.trim(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Your details were updated")),
      );
      Navigator.pop(context);
    } on FirebaseException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      showMessageDialog(context, "Update failed", e.message ?? e.code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Details")),
      body: ListView(
        padding: AppSpacing.page,
        children: [
          TextField(
            controller: _firstName,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
                labelText: "First name",
                prefixIcon: Icon(Icons.person_outline)),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _lastName,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
                labelText: "Last name", prefixIcon: Icon(Icons.person_outline)),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
                labelText: "Phone number",
                prefixIcon: Icon(Icons.phone_outlined)),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _address,
            decoration: const InputDecoration(
                labelText: "Address",
                prefixIcon: Icon(Icons.location_on_outlined)),
          ),
          const SizedBox(height: AppSpacing.lg),
          LoadingButton(
              label: "Save changes", loading: _saving, onPressed: _save),
        ],
      ),
    );
  }
}
