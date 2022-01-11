import 'package:flutter/cupertino.dart';
import 'package:ical/serializer.dart';
import 'dart:io';
import 'package:enough_icalendar/enough_icalendar.dart';

ICalendar createEvent(DateTime startTime, Map<String, String> meetData) {
  ICalendar cal = ICalendar();
  cal.addElement(
    IEvent(
      duration: Duration(minutes: 25),  //as of now just the default is 25
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

VCalendar newEvent(DateTime startTime, Map<String, String> meetData, String timezone){
  VCalendar x =  VCalendar.createEvent(
    start: DateTime(2022, 1,1),
    duration: IsoDuration(minutes: 25),
    location: "Online",
    summary: meetData["description"],
    description: meetData["link"],
    url: Uri.parse(meetData["link"] as String),
    //organizerEmail: "random@gmail.com",
    timezoneId: timezone,
    //organizer: OrganizerProperty("Random:"),
    //TODO

  );
  String a = x.toString();
  print ("ICS:\n" + a);
  return x;

}

Future<File> createSharableIcsFile(BuildContext context,
    Map<String, String> meetData, DateTime startTime, String timezone) async {
  ICalendar cal = createEvent(startTime, meetData);
  String ics = cal.serialize();
  VCalendar testIcs = newEvent(startTime, meetData, timezone);
  //ics = ics.replaceAll(new RegExp(r'BEGIN:VEVENT'), "BEGIN:VEVENT\nX-GOOGLE-CONFERENCE:https://meet.google.com/jum-gpmv-cti");

  // String split = "";
  // int i = 0;
  // while(ics[i] != "\n"){
  //   split = split + ics[i];
  //   ics.replaceAll(new RegExp(r'BEGIN:VCALENDER\n'), "BEGIN:VCALENDER\nreplaced");
  //
  // }
  //print("ICS:\n" + ics);
  String path = Directory.systemTemp.path;
  final fIcs = File("$path/meet.ics");
  return fIcs.writeAsString(testIcs.toString());
}
