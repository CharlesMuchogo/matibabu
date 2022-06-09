// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:flutter/material.dart';

import 'package:internationalization/internationalization.dart';
import 'package:matibabu/GlobalComponents/restapi.dart';

class BookingsPage extends StatefulWidget {
  @override
  State<BookingsPage> createState() => _BookingsPageState();
  final String address;
  const BookingsPage(this.address);
}

String _selectedDate = "";
String formatedTime = "";
String error = "Please fill in the details";
bool formfilled = true;

class _BookingsPageState extends State<BookingsPage> {
  Future<void> _openDatePicker(BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      helpText: "SELECT BOOKING DATE",
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

  _selectTime(BuildContext context) async {
    final TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if (timeOfDay != null && timeOfDay != selectedTime) {
      setState(() {
        selectedTime = timeOfDay;
        formatedTime = "${selectedTime.hour}:${selectedTime.minute}";
      });
    }
  }

  void book() {
    if ((formatedTime.isEmpty) || (_selectedDate.isEmpty)) {
      setState(
        () {
          formfilled = false;
        },
      );
    } else {
      setState(() {
        formfilled = false;
      });

      RestApi restObject = RestApi();
      restObject.bookAppointment(
          _dropdownValue, formatedTime, _selectedDate, widget.address);

      final snackBar = SnackBar(
        content: const Text('Your Appointment was booked successfully!'),
        backgroundColor: (Colors.grey[900]),
        action: SnackBarAction(
          label: 'dismiss',
          onPressed: () {},
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  List<String> doctorSpecialties = [
    "Therapy",
    "Cardiology",
    "Gaenacology",
    "Neurology",
    "Dentist"
  ];

  String _dropdownValue = "Therapy";

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
          SizedBox(
            height: (MediaQuery.of(context).size.height * 0.15),
            child: Center(
              child: formfilled
                  ? Text("")
                  : Text(
                      error,
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
            ),
          ),
          ListTile(
            leading: IconButton(
              onPressed: (() => _openDatePicker(context)),
              icon: Icon(Icons.medical_services_outlined),
            ),
            title: Text("Select the type of Appointment"),
            trailing: DropdownButton(
              value: _dropdownValue,
              onChanged: (value) {
                setState(() {
                  _dropdownValue = value.toString();
                });
              },
              items: doctorSpecialties.map((String items) {
                return DropdownMenuItem(
                  value: items,
                  child: Text(items),
                );
              }).toList(),
            ),
          ),
          InkWell(
            onTap: () => _openDatePicker(context),
            child: ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text("Select date of the Appointment"),
              trailing: Text(_selectedDate),
            ),
          ),
          InkWell(
            onTap: () => _selectTime(context),
            child: ListTile(
              leading: Icon(Icons.timelapse_sharp),
              title: Text("Select time of the Appointment"),
              trailing: Text("${selectedTime.hour}:${selectedTime.minute}"),
            ),
          ),
          ElevatedButton(
            onPressed: book,
            child: Text("Book Appointment"),
          )
        ],
      ),
    );
  }
}
