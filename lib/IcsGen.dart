import 'package:flutter/cupertino.dart';
import 'package:ical/serializer.dart';
import 'dart:io';

ICalendar createEvent(){
  ICalendar cal = ICalendar();
  cal.addElement(
    IEvent(
      start: DateTime(2019, 3, 6),
      url: 'https://pub.dartlang.org/packages/srt_parser',
      status: IEventStatus.CONFIRMED,
      location: 'Heilbronn',
      description:
      'Description',
      summary: 'Test',

    ),
  );
  return cal;
}

Future<File> createSharableIcsFile(BuildContext context) async {

  ICalendar cal = createEvent();
  String ics = cal.serialize();
  String path = Directory.systemTemp.path;
  final fIcs = File("$path/meet.ics");
  return fIcs.writeAsString(ics);


}