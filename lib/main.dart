import 'package:flutter/material.dart';
import 'package:gmeet_to_ics/Functions.dart' as functions;
import 'package:gmeet_to_ics/IcsGen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/calendar/v3.dart' as cal;
import 'calendar_client.dart';
import 'secrets.dart';

Future<void> main() async {
  // Tries to login as soon as app opens
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  var _clientID = new ClientId(Secret.getId(), "");
  const _scopes = const [cal.CalendarApi.calendarScope];
  await clientViaUserConsent(_clientID, _scopes, prompt)
      .then((AuthClient client) async {
    CalendarClient.calendar = cal.CalendarApi(client);
    print("Authenticated");
  });
  runApp(MyApp());
}

void prompt(String url) async {
  await launch(url);
}

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
  DateTime startT = new DateTime(0), endT = new DateTime(0);
  String timezone = "";
  String meetLink = "";
  Map<String, String>? meetData;
  List<String> timezones = [];
  List<String> test = ["one", "two", "three"];
  bool detailsChosen = false;
  bool isLoadingLink = false;
  CalendarClient calendarClient = new CalendarClient();

  String getLinkUIText(){
    if(!detailsChosen) return "Please choose above details to create link";
    if(isLoadingLink) return "Loading...";
    return meetLink;
  }

  void createConferenceLink(bool hasConferenceSupport, DateTime startT, DateTime endT){
    calendarClient.createConference(hasConferenceSupport, startT, endT);
  }

  void updateStates(){
    if(startT.year != 0 && startT.hour != 0 && timezone != ""){
      detailsChosen = true;
      createConferenceLink(true, startT, endT);
      setState(() {
        isLoadingLink = true;
      });
      calenderClientInsert();
         //To make sure the link has actually loaded because the link loads asynchronously
         //  if (calendarClient
         //      .getEvent()
         //      .conferenceData != null) {
         //  }


    }


  }

  void getTodayDate() {
    setState(() {
      startT = functions.getTodayDate();
    });
    updateStates();
  }

  void getTomorrowDate() {
    setState(() {
      startT = functions.getTomorrowDate();
    });
    updateStates();
  }

  void getSelectedDate(BuildContext context) async {
    startT = (await functions.getSelectedDate(context))!;
    setState(() {});
    updateStates();
  }

  void getSelectedTime(BuildContext context) async {
    TimeOfDay? startTime = await functions.getSelectedTime(context);
    startT = new DateTime(startT!.year, startT!.month, startT!.day,
        startTime!.hour, startTime.minute);
    setState(() {});
    int startHour = startTime.hour;
    int startMin = startTime.minute;
    int? endMin = 0;
    int endHour = 0;
    if (startMin + 25 < 60) {
      endMin = startMin + 25;
      endHour = startHour;
    } else if (startMin + 25 >= 60) {
      endMin = 25 - (60 - startMin);
      endHour = startHour + 1;
    }
    if (endHour > 23) {
      endHour = 0;
    }
    endT =
        new DateTime(startT!.year, startT!.month, startT!.day, endHour, endMin);
    setState(() {});
    updateStates();
  }

  void getTimeZone() async {
    timezone = await functions.getTimeZone();
    setState(() {});
    updateStates();
  }

  void getAvailableTimezones() async {
    timezones = await functions.getAvailableTimezones();
    setState(() {});
  }

  Future<void> calenderClientInsert() async {
    meetData = await calendarClient.insert(
      title: "Online meet",
      description: "Meet online",
      location: "Online",
      startTime: startT,
      endTime: endT,
      hasConferenceSupport: true,
      attendeeEmailList: List.empty(),
      shouldNotifyAttendees: false,
    );
    setState(() {
      if(isLoadingLink) isLoadingLink = false;
      meetLink = meetData!["link"] != null? meetData!["link"] as String:"Error loading meetlink.";
    });

  }

  void _shareIcs()  {
    createSharableIcsFile(context, meetData!, startT, timezone).then((value) {
      Share.shareFiles([value.path]);
    });
  }

  Future getStoragePermission() async {
    await Permission.storage.request();
  }

  void getPermission() {
    getStoragePermission();
  }

  @override
  void initState() {
    super.initState();
    getPermission();
    getTimeZone();
    getAvailableTimezones();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(onPressed: null, child: Text("Logout"))  //TODO add function
                ],
              ),
            ),
            Container(
                child: Text(
              startT.year == 0
                  ? 'Date: choose date'
                  : "Date: " +
                      startT.day.toString() + " - " + startT.month.toString() + " - " + startT.year.toString(),
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            )),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    child: ElevatedButton(
                      onPressed: () => this.getTodayDate(),
                      child: Text("Today"),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: ElevatedButton(
                        onPressed: this.getTomorrowDate,
                        child: Text("Tomorrow")),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: ElevatedButton(
                        onPressed: () => {this.getSelectedDate(context)},
                        child: Text("Select date")),
                  )
                ],
              ),
              padding: EdgeInsets.only(bottom: 15),
            ),
            //-------------------------------------//
            Text(
                startT.hour == 0
                    ? "choose time"
                    : "Time: " +
                        (startT.hour > 12 ? (startT.hour - 12).toString() : startT.hour.toString()) + " : " + startT.minute.toString() + (startT.hour < 12 ? " AM" : " PM"),
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    child: ElevatedButton(
                        onPressed: () => {this.getSelectedTime(context)},
                        child: Text(
                            "Pick time") //will be dynamic, if time selected, then time will be shown instead of "Pick time"
                    ),
                  ),

                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 20),
              child: Text(
                  "Timezone",
                textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

            ),
            Container(

              child: DropdownButton<String>(
                alignment: AlignmentDirectional.center,
                  focusColor: Colors.blue,
                  isExpanded: false,

                  value: timezone,

                  items: timezones.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? value){
                    setState(() {
                      timezone = value!;
                    });
                  }),
            ),

            Text("Link",
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(getLinkUIText()),
            Container(
                padding:
                    EdgeInsets.only(top: 100, bottom: 20, left: 80, right: 80),
                child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: _shareIcs,
                        child: Text(
                          "SHARE",
                          style: TextStyle(fontSize: 25),
                        ))))
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
