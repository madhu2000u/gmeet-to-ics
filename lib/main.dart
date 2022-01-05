import 'package:flutter/material.dart';
import 'package:gmeet_to_ics/AuthScreenDialog.dart';
import 'package:gmeet_to_ics/Functions.dart' as functions;
import 'package:gmeet_to_ics/IcsGen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(MyApp());
}

// GoogleSignIn _googleSignIn = GoogleSignIn(
//   scopes: <String>[
//     'email',
//     'https://www.googleapis.com/auth/calendar'
//   ]
// );

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gmeet to ICS',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Gmeet to ICS'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  var _current_user;
  DateTime? date;
  TimeOfDay? startTime, endTime;
  String timezone = "";

  void getTodayDate(){
    setState(() {
      date = functions.getTodayDate();
    });
  }
  void getTomorrowDate(){
    setState(() {
      date = functions.getTomorrowDate();
    });
  }

  void getSelectedDate(BuildContext context) async {
    date = await functions.getSelectedDate(context);
    setState(() {});
  }

  void getSelectedTime(BuildContext context) async {
    startTime = await functions.getSelectedTime(context);
    setState(() {});
    int startHour = startTime!.hour;
    int startMin = startTime!.minute;
    int? endMin = 0;
    int endHour = 0;
    if(startMin + 25 < 60){
      endMin = startMin + 25;
      endHour = startHour;
    }else if(startMin + 25 >= 60){
      endMin = 0;
      endHour = startHour + 1;
    }
    if(endHour > 23){
      endHour = 0;
    }
    endTime = new TimeOfDay(hour: endHour, minute: endMin);
  }

  void getTimeZone() async {
    timezone = await functions.getTimeZone();
    setState(() {});
  }

  void _incrementCounter() {
    createSharableIcsFile(context).then((value){
      Share.shareFiles([value.path]);
    });
  }

  Future getStoragePermission() async {
    await Permission.storage.request();
  }
  void getPermission(){
    getStoragePermission();
  }

  @override
  void initState() {
    super.initState();
    getPermission();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: //_current_user==null? AuthDialog():
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
                child:Text(
                  date == null?'Date:':"Date: "+date.toString(),   //TODO convert to human readable string, write another function for that ig
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                )
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    child:ElevatedButton(
                      onPressed: ()=> this.getTodayDate(), //TODO sample
                      child: Text("Today"),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child:ElevatedButton(
                        onPressed: this.getTomorrowDate,
                        child: Text("Tomorrow")
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child:ElevatedButton(
                        onPressed: ()=>{this.getSelectedDate(context)},
                        child: Text("Select date")
                    ),
                  )


                ],
              ) ,
              padding: EdgeInsets.only(bottom: 15),
            ),
            //-------------------------------------//
            Text(
              startTime == null?"Time:" : "Time:" + startTime.toString(),  //TODO convert to human readable
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)
            ),
            Container(
              padding: EdgeInsets.only(bottom: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    child: ElevatedButton(onPressed: ()=>{this.getSelectedTime(context)},
                        child: Text("Pick time") //will be dynamic, if time selected, then time will be shown instead of "Pick time"
                    ),
                  ),

                  Container(
                      padding: EdgeInsets.all(10),
                    child: ElevatedButton(onPressed: this.getTimeZone,
                        child: Column(
                          children: [
                            Text("Time zone"),
                            Text(timezone)  //will be dynamic
                          ],
                        )
                    )
                  )


                ],
              ),
            ),

            Text(
                "Link",
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text("the actual meet link"),
            Container(
              padding: EdgeInsets.only(top: 100, bottom: 20, left: 80, right: 80),
              child: SizedBox(
                width: double.infinity,
                  child:ElevatedButton(
                  onPressed: _incrementCounter,
                  child: Text(
                      "SHARE",
                    style: TextStyle(fontSize: 25),
                  )
                )
              )
            )

          ],
        ),
      ),
       // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
