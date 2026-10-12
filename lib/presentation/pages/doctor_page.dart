import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:matibabu/domain/entities/user.dart';
import 'package:matibabu/presentation/bloc/chats/chats_bloc.dart';
import 'package:matibabu/presentation/pages/booking_page.dart';
import 'package:matibabu/presentation/theme/app_theme.dart';
import 'package:matibabu/presentation/widgets/common.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageDoctorButton extends StatelessWidget {
  final User doctor;
  final bool tonal;

  const MessageDoctorButton(this.doctor, {super.key, this.tonal = false});

  @override
  Widget build(BuildContext context) {
    final opening = context.select(
      (ChatsBloc bloc) => bloc.state.openStatus.isLoading,
    );
    final onPressed = opening
        ? null
        : () => context.read<ChatsBloc>().add(ChatOpenRequested(doctor.id));
    final icon = opening
        ? const ButtonSpinner()
        : const Icon(Icons.chat_bubble_outline_rounded);
    return tonal
        ? FilledButton.tonalIcon(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            icon: icon,
            label: const Text("Message doctor"),
          )
        : OutlinedButton.icon(
            onPressed: onPressed,
            icon: icon,
            label: const Text("Message"),
          );
  }
}

class DoctorPage extends StatelessWidget {
  final User doctor;

  const DoctorPage({super.key, required this.doctor});

  Future<void> _openWhatsApp() async {
    var phone = doctor.phoneNumber.replaceAll(RegExp(r"[^0-9+]"), "");
    if (phone.startsWith("0")) phone = "+254${phone.substring(1)}";
    final uri = Uri.parse("whatsapp://send?phone=$phone&text=hello");
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final photo = doctor.profilePhoto;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 280,
            backgroundColor: scheme.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: photo.isEmpty
                  ? Image.asset(
                      "assets/images/emptyprofile.png",
                      fit: BoxFit.cover,
                    )
                  : Image.network(photo, fit: BoxFit.cover),
            ),
          ),
          SliverPadding(
            padding: AppSpacing.page,
            sliver: SliverList.list(
              children: [
                Text(
                  doctor.displayName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  doctor.specialty,
                  style: TextStyle(fontSize: 16, color: scheme.primary),
                ),
                const SizedBox(height: AppSpacing.md),
                Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.local_hospital_outlined,
                      color: scheme.primary,
                    ),
                    title: const Text(
                      "Current hospital",
                      style: TextStyle(fontSize: 13),
                    ),
                    subtitle: Text(
                      doctor.hospital,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SectionHeaderInline("About"),
                Text(
                  doctor.about,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SectionHeaderInline("Contact"),
                Row(
                  children: [
                    Expanded(
                      child: _ContactButton(
                        icon: const Icon(Icons.phone_outlined),
                        label: "Call",
                        onTap: () =>
                            launchUrl(Uri.parse("tel:${doctor.phoneNumber}")),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm + 4),
                    Expanded(
                      child: _ContactButton(
                        icon: const Icon(Icons.email_outlined),
                        label: "Email",
                        onTap: () =>
                            launchUrl(Uri.parse("mailto:${doctor.email}")),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm + 4),
                    Expanded(
                      child: _ContactButton(
                        icon: const FaIcon(
                          FontAwesomeIcons.whatsapp,
                          color: Color(0xFF25D366),
                        ),
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
          child: Row(
            children: [
              Expanded(child: MessageDoctorButton(doctor)),
              const SizedBox(width: AppSpacing.sm + 4),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => BookingPage(doctor: doctor),
                    ),
                  ),
                  child: const Text("Book"),
                ),
              ),
            ],
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

  const _ContactButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

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
                data: IconThemeData(
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: icon,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
