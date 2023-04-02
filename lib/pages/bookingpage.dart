// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';

import 'package:internationalization/internationalization.dart';
import 'package:matibabu/GlobalComponents/restapi.dart';

class BookingsPage extends StatefulWidget {
  @override
  State<BookingsPage> createState() => _BookingsPageState();
  final String address;
  final String doctorName;
  final String doctorUid;
  final String doctorspecialty;

  const BookingsPage(
    this.address,
    this.doctorName,
    this.doctorUid,
    this.doctorspecialty,
  );
}

String _selectedDate = "";
String formatedTime = "";
String timeOfAppointment = "";

class _BookingsPageState extends State<BookingsPage> {
  Future<void> _openDatePicker(BuildContext context) async {
    DateTime initialdate = DateTime.now();

    if (DateTime.now().weekday == 6) {
      setState(() {
        initialdate = initialdate.add(Duration(days: 2));
      });
    }
    if (DateTime.now().weekday == 7) {
      setState(() {
        initialdate = initialdate.add(Duration(days: 1));
      });
    }

    final DateTime? date = await showDatePicker(
      context: context,
      selectableDayPredicate: (DateTime val) =>
          val.weekday == 6 || val.weekday == 7 ? false : true,
      initialDate: initialdate,
      firstDate: DateTime.now(),
      helpText: "Select date of appointment",
      lastDate: DateTime(DateTime.now().year + 5),
    );

    if (date != null) {
      setState(
        () {
          _selectedDate = DateFormat.yMMMd("en_US").format(date).toString();
        },
      );
    }
    //return _selectedDate;
  }

  TimeOfDay selectedTime = TimeOfDay.now();

  Widget GetAppointmentTime(
      String doctorUid, BuildContext context, String date) {
    List appointmenttime = [];
    List availableAppointments = [];
    List doctorSchedule = [
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

    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("Doctor")
            .doc(doctorUid)
            .collection("My appointments")
            .where("Date", isEqualTo: date)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text("Oops, an error occured. please try again"),
            );
          }

          for (int i = 0; i < snapshot.data!.size; i++) {
            appointmenttime.add(snapshot.data!.docs[i]["Time"]);
          }
          availableAppointments.clear();
          for (int i = 0; i < doctorSchedule.length; i++) {
            if (!appointmenttime.contains(doctorSchedule[i])) {
              availableAppointments.add(doctorSchedule[i]);
            }
          }

          return InkWell(
            onTap: () {
              showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return GridView.count(
                      mainAxisSpacing: 1,
                      crossAxisCount: 4,
                      children:
                          List.generate(availableAppointments.length, (index) {
                        return Center(
                          child: selectTime(availableAppointments[index]),
                        );
                      }),
                    );
                  });
            },
            child: ListTile(
              leading: Icon(Icons.watch_later_outlined),
              title: Text("Select time of the Appointment"),
              trailing: Text(
                timeOfAppointment,
                style: TextStyle(color: Colors.teal),
              ),
            ),
          );
        });
  }

  Widget selectTime(String time) {
    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 0),
      child: ElevatedButton(
          onPressed: () {
            setState(() {
              timeOfAppointment = time;
            });
          },
          child: Text(time)),
    );
  }

  book() {
    if ((timeOfAppointment.isEmpty) || (_selectedDate.isEmpty)) {
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Error!"),
              content: Text("Fill in all details"),
              actions: [
                MaterialButton(
                  child: Text("Okay"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            );
          });
    } else {
      RestApi restObject = RestApi();
      restObject.bookAppointment(
          widget.doctorspecialty,
          timeOfAppointment,
          _selectedDate,
          widget.address,
          widget.doctorName,
          widget.doctorUid,
          context);
    }
    setState(() {
      _selectedDate = "";
      timeOfAppointment = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Book An Appointment"),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Center(
            child: SizedBox(
              height: (MediaQuery.of(context).size.height * 0.15),
              child: Center(
                child: Text(
                  "Pick a date and time of your appointment",
                  style: TextStyle(
                      color: Colors.teal,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () => _openDatePicker(context),
            child: ListTile(
              leading: Icon(Icons.calendar_month_outlined),
              title: Text("Select date of the Appointment"),
              trailing: Text(
                _selectedDate,
                style: TextStyle(color: Colors.teal),
              ),
            ),
          ),
          GetAppointmentTime(widget.doctorUid, context, _selectedDate),
          ElevatedButton(
            onPressed: book,
            child: Text("Book Appointment"),
          )
        ],
      ),
    );
  }
}
