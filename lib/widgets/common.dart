import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:matibabu/GlobalComponents/authenticationservice.dart';
import 'package:matibabu/models/appointment.dart';
import 'package:matibabu/theme/app_theme.dart';
import 'package:provider/provider.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader(this.title, {super.key, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.lg, AppSpacing.sm, AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          if (actionLabel != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

/// Section title for use inside an already-padded column.
class SectionHeaderInline extends StatelessWidget {
  final String title;
  final Widget? action;
  const SectionHeaderInline(this.title, {super.key, this.action});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          top: action == null ? AppSpacing.lg : AppSpacing.md,
          bottom: action == null ? AppSpacing.sm : 0),
      child: Row(
        children: [
          Expanded(
            child: Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

Color statusColor(String status) {
  switch (status) {
    case "Confirmed":
      return AppColors.confirmed;
    case "Cancelled":
      return AppColors.cancelled;
    case "Completed":
      return AppColors.completed;
    default:
      return AppColors.pending;
  }
}

class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final color = statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm + 2, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        status,
        style:
            TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class Avatar extends StatelessWidget {
  final String? url;
  final double radius;
  const Avatar(this.url, {super.key, this.radius = 24});

  @override
  Widget build(BuildContext context) {
    final hasUrl = url != null && url!.isNotEmpty;
    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      backgroundImage: hasUrl
          ? NetworkImage(url!)
          : const AssetImage("assets/images/emptyprofile.png") as ImageProvider,
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  const EmptyState(
      {super.key, required this.icon, required this.title, this.message});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: scheme.primaryContainer,
            child: Icon(icon, size: 32, color: scheme.primary),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(title,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(message!,
                textAlign: TextAlign.center,
                style: TextStyle(color: scheme.onSurfaceVariant)),
          ],
        ],
      ),
    );
  }
}

class LoadingView extends StatelessWidget {
  final double? height;
  const LoadingView({super.key, this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.error_outline,
      title: "Something went wrong",
      message: "Please try again later.",
    );
  }
}

/// Small icon + text pair used for dates, times and locations.
class IconLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  const IconLabel(this.icon, this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: color, fontSize: 13)),
        ),
      ],
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback? onTap;
  const AppointmentCard(this.appointment, {super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: AppSpacing.card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: scheme.primaryContainer,
                    child: Icon(Icons.medical_services_outlined,
                        color: scheme.primary, size: 22),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(appointment.doctorName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 16)),
                        const SizedBox(height: 2),
                        Text(appointment.consultation,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: scheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  StatusChip(appointment.displayStatus),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Row(
                  children: [
                    Expanded(
                        child: IconLabel(
                            Icons.calendar_today_outlined, appointment.date)),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                        child: IconLabel(
                            Icons.access_time_rounded, appointment.time)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DoctorTile extends StatelessWidget {
  final String name;
  final String specialty;
  final String? photoUrl;
  final VoidCallback? onTap;
  const DoctorTile({
    super.key,
    required this.name,
    required this.specialty,
    this.photoUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: AppSpacing.card,
          child: Row(
            children: [
              Avatar(photoUrl, radius: 28),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(specialty,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: scheme.primary)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows a yes/no confirmation dialog and resolves to true on confirm.
Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  String? message,
  String confirmLabel = "Yes",
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: message == null ? null : Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: destructive
              ? TextButton.styleFrom(foregroundColor: AppColors.cancelled)
              : null,
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

void showMessageDialog(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Okay"),
        ),
      ],
    ),
  );
}

/// Brand mark shown at the top of the auth screens.
class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const AuthHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 64,
          width: 64,
          decoration: BoxDecoration(
            color: scheme.primary,
            borderRadius: BorderRadius.circular(AppSpacing.radius),
          ),
          child: const Icon(Icons.health_and_safety_rounded,
              color: Colors.white, size: 36),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(title,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
        const SizedBox(height: AppSpacing.xs),
        Text(subtitle,
            style: TextStyle(fontSize: 15, color: scheme.onSurfaceVariant)),
      ],
    );
  }
}

/// Filled button that swaps its label for a spinner while [loading].
class LoadingButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback onPressed;
  const LoadingButton(
      {super.key,
      required this.label,
      required this.loading,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: loading ? null : onPressed,
      child: loading
          ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5))
          : Text(label),
    );
  }
}

/// "Continue with Google" button shared by the login and sign-up screens.
class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({super.key});

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _loading = false;

  Future<void> _signIn() async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _loading = true);
    try {
      await context.read<AuthenticationService>().signInWithGoogle();
      // Sign up is pushed over login; return to the root so the auth
      // wrapper can show the app.
      navigator.popUntil((route) => route.isFirst);
    } on GoogleSignInException catch (e) {
      debugPrint("Google sign in failed: $e");
      if (!mounted) return;
      // Android reports an unregistered SHA-1 / OAuth client as a cancel
      // ("[16] Account reauth failed"), so only treat it as a real cancel
      // when that isn't the reason.
      final misconfigured = e.description?.contains("[16]") ?? false;
      if (!misconfigured &&
          (e.code == GoogleSignInExceptionCode.canceled ||
              e.code == GoogleSignInExceptionCode.interrupted)) {
        messenger.showSnackBar(
          const SnackBar(content: Text("Google sign in was cancelled")),
        );
      } else {
        showMessageDialog(
          context,
          "Google sign in failed",
          misconfigured
              ? "Google sign in isn't set up for this build of the app. "
                  "Add this app's SHA-1 fingerprint in the Firebase console "
                  "and try again.\n\n(${e.description})"
              : e.description ?? e.code.name,
        );
      }
    } on FirebaseException catch (e) {
      debugPrint("Google sign in failed: $e");
      if (mounted) {
        showMessageDialog(
            context, "Google sign in failed", e.message ?? e.code);
      }
    } catch (e) {
      debugPrint("Google sign in failed: $e");
      if (mounted) {
        showMessageDialog(context, "Google sign in failed", e.toString());
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _loading ? null : _signIn,
      style: OutlinedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        backgroundColor: Colors.white,
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      icon: _loading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2.5))
          : const FaIcon(FontAwesomeIcons.google,
              size: 18, color: Color(0xFF4285F4)),
      label: const Text("Continue with Google"),
    );
  }
}

/// Horizontal "or" divider between sign-in options.
class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text("or", style: TextStyle(color: color)),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }
}
