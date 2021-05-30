import 'package:flutter/material.dart';

import 'package:logo_recognizer/features/recognizer/recognition.dart';

class RecognitionWidget extends StatelessWidget {
  final Recognition recognition;

  RecognitionWidget(this.recognition);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: recognition.x,
      top: recognition.y,
      child: Container(
        width: recognition.w,
        height: recognition.h,
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: Colors.blue,
          ),
        ),
        child: Align(
          alignment: Alignment.topLeft,
          child: Container(
            color: Colors.blue,
            child: Text(
              recognition.label,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
