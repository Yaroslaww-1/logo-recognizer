import 'package:flutter/material.dart';

import 'package:logo_recognizer/routes_enum.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen();

  @override
  _HomeScreenState createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void onUseSSDClick() {
    Navigator.pushNamed(context, RouteEnum.SSD_RECOGNIZER);
  }

  void onUseYOLOClick() {
    Navigator.pushNamed(context, RouteEnum.YOLO_RECOGNIZER);
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
                    "Use SSD",
                    style: TextStyle(fontSize: 25.0),
                  ),
                  onPressed: onUseSSDClick,
                ),
              ),
              ButtonTheme(
                child: ElevatedButton(
                  child: Text(
                    "Use YOLO (much slower than SSD)",
                    style: TextStyle(fontSize: 25.0),
                  ),
                  onPressed: onUseYOLOClick,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
