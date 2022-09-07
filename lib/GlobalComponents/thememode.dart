import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  ThemeData darkTheme() {
    return ThemeData(
      appBarTheme: AppBarTheme(
          color: Colors.teal, systemOverlayStyle: SystemUiOverlayStyle.dark),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.grey),
        labelStyle: TextStyle(color: Colors.white),
      ),
      brightness: Brightness.dark,
      canvasColor: Colors.grey,
      colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.grey)
          .copyWith(secondary: Colors.amber),
    );
  }
}
