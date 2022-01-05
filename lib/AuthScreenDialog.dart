import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/calendar/v3.dart' as cal;
import 'calendar_client.dart';
import 'secrets.dart';

class AuthDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _AuthDialogState();
  }
}

class _AuthDialogState extends State<AuthDialog> {
  bool isLoading = false;

  Future<void> handleSignIn() async {
    setState(() {
      isLoading = true;
    });
    try {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();

      var _clientID = new ClientId(Secret.getId(), "");
      const _scopes = const [cal.CalendarApi.calendarScope];
      await clientViaUserConsent(_clientID, _scopes, prompt)
          .then((AuthClient client) async {
        CalendarClient.calendar = cal.CalendarApi(client);
      });
      setState(() {
        isLoading = false;
      });
    } catch (error) {
      print(error);
    }
  }

  void prompt(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(20),
                child: Text(
                  "Please authorize with google.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              Container(
                child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          isLoading ? Colors.grey : Colors.blue)),
                  onPressed: handleSignIn,
                  child: Text(
                      !isLoading ? "Sign in with Google" : "Signing in..."),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
