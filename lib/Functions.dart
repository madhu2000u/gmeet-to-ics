

import 'package:flutter/material.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

//Format of function return 2022-01-05 17:09:53.177392
DateTime getTodayDate(){
  print(DateTime.now());
  return DateTime.now();
}
//Format of function return 2022-01-05 17:09:53.177392
DateTime getTomorrowDate(){
  DateTime now = DateTime.now();
  print (now);
  return DateTime(now.year, now.month, now.day + 1);

}

//Format of function return 2022-01-06 00:00:00.000
Future<DateTime?> getSelectedDate(BuildContext context) async{
  DateTime? selected = await showDatePicker(context: context,initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(3000));
  print(selected);
  return selected;
}

//Format of function return "TimeOfDay(17:12)"
Future<TimeOfDay?> getSelectedTime(BuildContext context) async{
  TimeOfDay? selected = await showTimePicker(context: context, initialTime: TimeOfDay.now());
  print(selected);
  return selected;
}

Future<String> getTimeZone() async {
  try{
    String timezone = await FlutterNativeTimezone.getLocalTimezone();
    //print(await FlutterNativeTimezone.getAvailableTimezones());
    return timezone;
  }catch(e){
    print("Error fetching time zone: " + e.toString());
    return "Error fetching time zone" + e.toString();
  }
  // String timezone = DateTime.now().timeZoneName;
  // print(timezone);
  // if(timezone == "+04") return "IST";
  // else return ("GMT "+ timezone);
}

Future<List<String>> getAvailableTimezones() async {
  try{
    List<String> timezones = await FlutterNativeTimezone.getAvailableTimezones();
    return timezones;
  }catch(e){
    return <String>["Error fetching available time zones"];
  }
}

