import 'package:flutter/material.dart';

import 'features/recognizer/recognizer_screen.dart';
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

// title: Text('Logo Recognizer'),

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
        RouteEnum.RECOGNIZER: (context) => RecognizerScreen()
      },
    );
  }
}
