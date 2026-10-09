import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:matibabu/GlobalComponents/restapi.dart';
import 'package:matibabu/theme/app_theme.dart';
import 'package:matibabu/widgets/common.dart';

const List<String> _doctorSchedule = [
  "08:00 AM",
  "08:30 AM",
  "09:00 AM",
  "09:30 AM",
  "10:00 AM",
  "10:30 AM",
  "11:00 AM",
  "11:30 AM",
  "12:00 PM",
  "12:30 PM",
  "2:00 PM",
  "2:30 PM",
  "3:00 PM",
  "3:30 PM",
  "4:00 PM",
];

class BookingsPage extends StatefulWidget {
  final String address;
  final String doctorName;
  final String doctorUid;
  final String doctorSpecialty;

  const BookingsPage({
    super.key,
    required this.address,
    required this.doctorName,
    required this.doctorUid,
    required this.doctorSpecialty,
  });

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  String _selectedDate = "";
  String _selectedTime = "";
  bool _booking = false;

  bool _isWeekend(DateTime d) =>
      d.weekday == DateTime.saturday || d.weekday == DateTime.sunday;

  Future<void> _openDatePicker() async {
    var initial = DateTime.now();
    while (_isWeekend(initial)) {
      initial = initial.add(const Duration(days: 1));
    }

    final date = await showDatePicker(
      context: context,
      selectableDayPredicate: (d) => !_isWeekend(d),
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 5),
      helpText: "Select date of appointment",
    );

    if (date != null) {
      setState(() {
        _selectedDate = DateFormat.yMMMd("en_US").format(date);
        _selectedTime = "";
      });
    }
  }

  Future<void> _book() async {
    if (_selectedDate.isEmpty || _selectedTime.isEmpty) {
      showMessageDialog(
          context, "Missing details", "Pick both a date and a time.");
      return;
    }

    setState(() => _booking = true);
    try {
      await RestApi().bookAppointment(
        widget.doctorSpecialty,
        _selectedTime,
        _selectedDate,
        widget.address,
        widget.doctorName,
        widget.doctorUid,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Your appointment was booked!")),
      );
      Navigator.pop(context);
    } on FirebaseException catch (e) {
      if (!mounted) return;
      setState(() => _booking = false);
      showMessageDialog(context, "Booking failed", e.message ?? e.code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Book Appointment")),
      body: ListView(
        padding: AppSpacing.page,
        children: [
          DoctorTile(
              name: widget.doctorName, specialty: widget.doctorSpecialty),
          const SizedBox(height: AppSpacing.lg),
          Text("Date",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.sm),
          Card(
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              onTap: _openDatePicker,
              leading:
                  Icon(Icons.calendar_today_outlined, color: scheme.primary),
              title:
                  Text(_selectedDate.isEmpty ? "Select a date" : _selectedDate),
              subtitle: const Text("Monday to Friday"),
              trailing: const Icon(Icons.chevron_right_rounded),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text("Time",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.sm),
          _selectedDate.isEmpty
              ? Text("Pick a date to see available times.",
                  style: TextStyle(color: scheme.onSurfaceVariant))
              : _timeSlots(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: AppSpacing.page,
          child: LoadingButton(
              label: "Book Appointment", loading: _booking, onPressed: _book),
        ),
      ),
    );
  }

  Widget _timeSlots() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("Doctor")
          .doc(widget.doctorUid)
          .collection("My appointments")
          .where("Date", isEqualTo: _selectedDate)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const ErrorView();
        if (!snapshot.hasData) return const LoadingView(height: 120);

        final taken = snapshot.data!.docs.map((d) => d["Time"]).toSet();
        final available =
            _doctorSchedule.where((t) => !taken.contains(t)).toList();

        if (available.isEmpty) {
          return const EmptyState(
            icon: Icons.event_busy_outlined,
            title: "Fully booked",
            message: "Try another date.",
          );
        }

        return Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final t in available)
              ChoiceChip(
                label: Text(t),
                selected: _selectedTime == t,
                showCheckmark: false,
                onSelected: (_) => setState(() => _selectedTime = t),
              ),
          ],
        );
      },
    );
  }
}
