import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:matibabu/models/appointment.dart';
import 'package:matibabu/pages/appointment.dart';
import 'package:matibabu/pages/doctor_information.dart';
import 'package:matibabu/pages/doctorcartegories.dart';
import 'package:matibabu/pages/doctorcategoriesexpanded.dart';
import 'package:matibabu/theme/app_theme.dart';
import 'package:matibabu/widgets/common.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _Header(uid),
          const SectionHeader("Upcoming appointments"),
          _UpcomingAppointments(uid),
          SectionHeader(
            "Doctor categories",
            actionLabel: "See all",
            onAction: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DoctorCartegories()),
            ),
          ),
          const _Categories(),
          const SectionHeader("Top rated specialists"),
          const _TopDoctors(),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

String _greeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}

class _Header extends StatelessWidget {
  final String uid;
  const _Header(this.uid);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream:
          FirebaseFirestore.instance.collection("Patient").doc(uid).snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        final name = data?["First Name"] ?? "";

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF008080), Color(0xFF0FA3A3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(AppSpacing.radius * 1.5),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, AppSpacing.lg, AppSpacing.md, AppSpacing.xl),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting(),
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 15),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          "How are you feeling today?",
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85)),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: Avatar(data?["Profile Photo"], radius: 26),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _UpcomingAppointments extends StatelessWidget {
  final String uid;
  const _UpcomingAppointments(this.uid);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("Patient")
          .doc(uid)
          .collection("My appointments")
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const ErrorView();
        if (!snapshot.hasData) return const LoadingView(height: 140);

        final upcoming = Appointment.fromQuery(snapshot.data!)
            .where((a) => a.isUpcoming)
            .toList();

        if (upcoming.isEmpty) {
          return Padding(
            padding: AppSpacing.pageHorizontal,
            child: Card(
              child: Padding(
                padding: AppSpacing.card,
                child: Row(
                  children: [
                    Icon(Icons.event_available_outlined,
                        color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: AppSpacing.md),
                    const Expanded(
                      child: Text("No upcoming appointments. "
                          "Book a specialist below."),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return SizedBox(
          height: 152,
          child: ListView.separated(
            padding: AppSpacing.pageHorizontal,
            scrollDirection: Axis.horizontal,
            itemCount: upcoming.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: AppSpacing.sm + 4),
            itemBuilder: (context, index) => SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.82,
              child: AppointmentCard(
                upcoming[index],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => AppointmentPage(upcoming[index])),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Categories extends StatelessWidget {
  const _Categories();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance.collection("Doctor Categoty").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const ErrorView();
        if (!snapshot.hasData) return const LoadingView(height: 112);

        final docs = snapshot.data!.docs;
        return SizedBox(
          height: 112,
          child: ListView.separated(
            padding: AppSpacing.pageHorizontal,
            scrollDirection: Axis.horizontal,
            itemCount: docs.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: AppSpacing.sm + 4),
            itemBuilder: (context, index) => SizedBox(
              width: 96,
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          DoctorCategoriesExpanded(category: docs[index].id),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Avatar(docs[index]["DisplayPhoto"], radius: 24),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          docs[index].id,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TopDoctors extends StatelessWidget {
  const _TopDoctors();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("Doctor").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const ErrorView();
        if (!snapshot.hasData) return const LoadingView(height: 120);

        return Padding(
          padding: AppSpacing.pageHorizontal,
          child: Column(
            children: [
              for (final doc in snapshot.data!.docs.take(5))
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm + 4),
                  child: DoctorListTile(doc),
                ),
            ],
          ),
        );
      },
    );
  }
}
