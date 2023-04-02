import 'package:flutter/material.dart';

class history extends StatelessWidget {
  const history({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Medical History"),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          "Your medical history will appear here",
        ),
      ),
    );
  }
}
