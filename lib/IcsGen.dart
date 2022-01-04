import 'package:flutter/cupertino.dart';
import 'package:ical/serializer.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

ICalendar createEvent(){
  ICalendar cal = ICalendar();
  cal.addElement(
    IEvent(


      uid: 'test@example.com',
      start: DateTime(2019, 3, 6),
      url: 'https://pub.dartlang.org/packages/srt_parser',
      status: IEventStatus.CONFIRMED,
      location: 'Heilbronn',
      description:
      'Arman and Adrian released their SRT-file parser library for Dart',
      summary: 'SRT-file Parser Release',

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