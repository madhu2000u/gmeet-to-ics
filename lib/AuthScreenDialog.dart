import 'package:flutter/material.dart';

class AuthDialog extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    return new _AuthDialogState();
  }
  
}

class _AuthDialogState extends State<AuthDialog>{

  bool isLoading = false;

  Future<void> handleSignIn() async{
    setState(() {
      isLoading = true;
    });
    try{
      //(Duration(seconds: 3));
       //await googleSignIn!.signIn();
      setState(() {
        isLoading = false;
      });
    }catch(error){
      print("error");
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
                  backgroundColor: MaterialStateProperty.all(isLoading?Colors.grey:Colors.blue)
                ),
                onPressed: handleSignIn,
                child: Text(!isLoading? "Sign in with Google": "Signing in..."),
              ),
            )
          ],
        ),
      )],

    );
  }

}