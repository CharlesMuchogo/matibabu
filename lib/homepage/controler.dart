DateTime now = DateTime.now();

String time() {
  String time = (now.hour.toString() +
      ":" +
      now.minute.toString() +
      ":" +
      now.second.toString());

  return time;
}
