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
    return RotatedBox(
      quarterTurns: 1,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(20.0),
          child: AppBar(
            centerTitle: true,
            title: const Text('TFlite Real Time Classification'),
          ),
        ),
        body: Center(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ButtonTheme(
                  child: ElevatedButton(
                    child: Text(
                      "Start Classification",
                      style: TextStyle(fontSize: 25.0),
                    ),
                    onPressed: onStartClassificationClick,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
