import 'package:flutter/material.dart';

import 'package:logo_recognizer/routes_enum.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen();

  @override
  _HomeScreenState createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void onStartClassificationClick() {
    Navigator.pushNamed(context, RouteEnum.RECOGNIZER);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ButtonTheme(
                child: ElevatedButton(
                  child: Text(
                    "Start",
                    style: TextStyle(fontSize: 25.0),
                  ),
                  onPressed: onStartClassificationClick,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
