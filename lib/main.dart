import 'package:flutter/material.dart';

import 'package:logo_recognizer/features/recognizer/ssd/ssd_recognizer_screen.dart';
import 'package:logo_recognizer/features/recognizer/yolo/yolo_recognizer_screen.dart';
import 'features/home/home_screen.dart';
import 'routes_enum.dart';

void main() {
  runApp(LogoRecognizer());
}

class LogoRecognizer extends StatefulWidget {
  LogoRecognizer({Key key}) : super(key: key);

  @override
  _LogoRecognizerState createState() => _LogoRecognizerState();
}

class _LogoRecognizerState extends State<LogoRecognizer> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Logo Recognizer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: RouteEnum.HOME,
      routes: {
        RouteEnum.HOME: (context) => HomeScreen(),
        RouteEnum.SSD_RECOGNIZER: (context) => SSDRecognizerScreen(),
        RouteEnum.YOLO_RECOGNIZER: (context) => YOLORecognizerScreen()
      },
    );
  }
}
