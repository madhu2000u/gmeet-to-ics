import 'package:flutter/cupertino.dart';
import 'package:ical/serializer.dart';
import 'dart:io';

ICalendar createEvent(DateTime startTime, Map<String, String> meetData) {
  ICalendar cal = ICalendar();
  cal.addElement(
    IEvent(
      start: startTime,
      url: meetData["link"],
      status: IEventStatus.CONFIRMED,
      location: "Online",
      description: meetData["link"],
      summary: meetData["description"],
    ),
  );
  return cal;
}

Future<File> createSharableIcsFile(BuildContext context,
    Map<String, String> meetData, DateTime startTime) async {
  ICalendar cal = createEvent(startTime, meetData);
  String ics = cal.serialize();
  // String split = "";
  // int i = 0;
  // while(ics[i] != "\n"){
  //   split = split + ics[i];
  //   ics.replaceAll(new RegExp(r'BEGIN:VCALENDER\n'), "BEGIN:VCALENDER\nreplaced");
  //
  // }
  print("ICS:\n" + ics);
  String path = Directory.systemTemp.path;
  final fIcs = File("$path/meet.ics");
  return fIcs.writeAsString(ics);
}
