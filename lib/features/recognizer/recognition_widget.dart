import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:logo_recognizer/features/recognizer/recognition.dart';

class RecognitionWidget extends StatelessWidget {
  final Recognition recognition;

  RecognitionWidget(this.recognition);

  @override
  Widget build(BuildContext context) {
    print(recognition);

    return Positioned(
      left: math.max(0, recognition.location.left),
      top: math.max(0, recognition.location.top),
      width: recognition.location.width,
      height: recognition.location.height,
      child: Container(
        padding: EdgeInsets.only(top: 5.0, left: 5.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: Color.fromRGBO(37, 213, 253, 1.0),
            width: 3.0,
          ),
        ),
        child: Text(
          "${recognition.label} ${(recognition.confidence * 100).toStringAsFixed(0)}%",
          style: TextStyle(
            color: Color.fromRGBO(37, 213, 253, 1.0),
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
