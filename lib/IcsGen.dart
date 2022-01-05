import 'package:flutter/cupertino.dart';
import 'package:ical/serializer.dart';
import 'dart:io';

ICalendar createEvent(){
  ICalendar cal = ICalendar();
  cal.addElement(
    IEvent(
      start: DateTime(2022, 1, 6),
      url: 'https://meet.google.com/jum-gpmv-cti',
      status: IEventStatus.CONFIRMED,
      location: 'Heilbronn',

      description:
      'desc\n\n-::~:~::~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~::~:~::-\nDo not edit this section of the description.\n\nThis event has a video call.\nJoin: https://meet.google.com/jum-gpmv-cti\n-::~:~::~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~::~:~::-',
      summary: 'Test',

    ),
  );

  //String event = "BEGIN:VCALENDAR\nSUMMARY:Test\nLOCATION:Googleplex\nSTATUS:CONFIRMED\nDESCRIPTION: desc\n\n-::~:~::~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~::~:~::-\nDo not edit this section of the description.\n\nThis event has a video call.\nJoin: https://meet.google.com/jum-gpmv-cti\n-::~:~::~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~:~::~:~::-";
  return cal;
}

Future<File> createSharableIcsFile(BuildContext context) async {

  ICalendar cal = createEvent();
  String ics = cal.serialize();
  ics = ics.replaceAll(new RegExp(r'BEGIN:VEVENT'), "BEGIN:VEVENT\nX-GOOGLE-CONFERENCE:https://meet.google.com/jum-gpmv-cti");

  // String split = "";
  // int i = 0;
  // while(ics[i] != "\n"){
  //   split = split + ics[i];
  //   ics.replaceAll(new RegExp(r'BEGIN:VCALENDER\n'), "BEGIN:VCALENDER\nreplaced");
  //
  // }
  print("ICS:\n"+ ics);
  String path = Directory.systemTemp.path;
  final fIcs = File("$path/meet.ics");
  return fIcs.writeAsString(ics);


}