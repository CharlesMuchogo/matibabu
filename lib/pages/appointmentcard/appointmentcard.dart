import 'package:flutter/material.dart';
import 'package:matibabu/GlobalComponents/restapi.dart';

class AppointmentCard extends StatelessWidget {
  final AppointmentDetails _appointmentDetails;

  AppointmentCard(this._appointmentDetails);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Text(_appointmentDetails.date.toString()),
          Text(_appointmentDetails.runtimeType.toString()),
          Text(_appointmentDetails.address.toString()),
        ],
      ),
    );
  }
}
