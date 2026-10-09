import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:matibabu/pages/bookingpage.dart';
import 'package:matibabu/theme/app_theme.dart';
import 'package:matibabu/widgets/common.dart';
import 'package:url_launcher/url_launcher.dart';

String doctorDisplayName(Map<String, dynamic> data) =>
    "Dr. ${data["First Name"] ?? ""} ${data["Last Name"] ?? ""}".trim();

/// A doctor row that opens the doctor's profile when tapped.
class DoctorListTile extends StatelessWidget {
  final DocumentSnapshot doc;
  const DoctorListTile(this.doc, {super.key});

  @override
  Widget build(BuildContext context) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return DoctorTile(
      name: doctorDisplayName(data),
      specialty: data["specialty"] ?? "",
      photoUrl: data["Profile Photo"],
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DoctorInfo(doctorId: doc.id)),
      ),
    );
  }
}

class DoctorInfo extends StatelessWidget {
  final String doctorId;

  const DoctorInfo({super.key, required this.doctorId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection("Doctor")
          .doc(doctorId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
              appBar: AppBar(), body: const Center(child: ErrorView()));
        }
        final data = snapshot.data?.data();
        if (data == null) {
          return Scaffold(appBar: AppBar(), body: const LoadingView());
        }
        return _DoctorInfoBody(doctorId: doctorId, data: data);
      },
    );
  }
}

class _DoctorInfoBody extends StatelessWidget {
  final String doctorId;
  final Map<String, dynamic> data;
  const _DoctorInfoBody({required this.doctorId, required this.data});

  String get _phone => data["Phone Number"] ?? "";
  String get _email => data["Email"] ?? "";
  String get _hospital => data["Current Hospital"] ?? "";
  String get _specialty => data["specialty"] ?? "";

  Future<void> _openWhatsApp() async {
    var phone = _phone.replaceAll(RegExp(r"[^0-9+]"), "");
    if (phone.startsWith("0")) phone = "+254${phone.substring(1)}";
    final uri = Uri.parse("whatsapp://send?phone=$phone&text=hello");
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final name = doctorDisplayName(data);
    final photo = data["Profile Photo"] as String?;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 280,
            backgroundColor: scheme.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: photo == null || photo.isEmpty
                  ? Image.asset("assets/images/emptyprofile.png",
                      fit: BoxFit.cover)
                  : Image.network(photo, fit: BoxFit.cover),
            ),
          ),
          SliverPadding(
            padding: AppSpacing.page,
            sliver: SliverList.list(
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.w700)),
                const SizedBox(height: AppSpacing.xs),
                Text(_specialty,
                    style: TextStyle(fontSize: 16, color: scheme.primary)),
                const SizedBox(height: AppSpacing.md),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.local_hospital_outlined,
                        color: scheme.primary),
                    title: const Text("Current hospital",
                        style: TextStyle(fontSize: 13)),
                    subtitle: Text(_hospital,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500)),
                  ),
                ),
                const SectionHeaderInline("About"),
                Text(
                  data["Description"] ?? "",
                  style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: scheme.onSurfaceVariant),
                ),
                const SectionHeaderInline("Contact"),
                Row(
                  children: [
                    Expanded(
                      child: _ContactButton(
                        icon: const Icon(Icons.phone_outlined),
                        label: "Call",
                        onTap: () => launchUrl(Uri.parse("tel:$_phone")),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm + 4),
                    Expanded(
                      child: _ContactButton(
                        icon: const Icon(Icons.email_outlined),
                        label: "Email",
                        onTap: () => launchUrl(Uri.parse("mailto:$_email")),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm + 4),
                    Expanded(
                      child: _ContactButton(
                        icon: const FaIcon(FontAwesomeIcons.whatsapp,
                            color: Color(0xFF25D366)),
                        label: "WhatsApp",
                        onTap: _openWhatsApp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: AppSpacing.page,
          child: FilledButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BookingsPage(
                  address: _hospital,
                  doctorName: name,
                  doctorUid: doctorId,
                  doctorSpecialty: _specialty,
                ),
              ),
            ),
            child: const Text("Book Appointment"),
          ),
        ),
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onTap;
  const _ContactButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Column(
            children: [
              IconTheme(
                data:
                    IconThemeData(color: Theme.of(context).colorScheme.primary),
                child: icon,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(label,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
