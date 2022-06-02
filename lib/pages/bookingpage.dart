// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

import 'package:internationalization/internationalization.dart';
import 'package:matibabu/GlobalComponents/restapi.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({Key? key}) : super(key: key);

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

String _selectedDate = "";
String formatedTime = "";
String error = "Please fill in the details";
bool detailsAreEmpty = false;

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
          detailsAreEmpty = true;
        },
      );
    } else {
      RestApi restObject = RestApi();
      restObject.bookAppointment(_dropdownValue, formatedTime, _selectedDate);

      setState(() {
        detailsAreEmpty = false;
      });

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
        backgroundColor: Color.fromRGBO(43, 147, 128, 20),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: (MediaQuery.of(context).size.height * 0.15),
            child: Center(
              child: detailsAreEmpty
                  ? Text(
                      error,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    )
                  : Text(""),
            ),
          ),
          Text(
            error,
            style: TextStyle(color: Colors.red, fontSize: 18),
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
