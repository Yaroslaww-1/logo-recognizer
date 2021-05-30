import 'package:flutter/material.dart';

import 'package:logo_recognizer/features/recognizer/yolo/yolo_camera_widget.dart';
import 'package:logo_recognizer/features/recognizer/recognition.dart';
import 'package:logo_recognizer/features/recognizer/recognition_widget.dart';

class YOLORecognizerScreen extends StatefulWidget {
  @override
  _YOLORecognizerScreenState createState() => new _YOLORecognizerScreenState();
}

class _YOLORecognizerScreenState extends State<YOLORecognizerScreen> {
  List<Recognition> _recognitions;

  void setRecognitions(
      List<Recognition> recognitions, int imageHeight, int imageWidth) {
    print("YOLO $recognitions");

    if (!mounted) {
      return;
    }

    setState(() {
      _recognitions = recognitions;
    });
  }

  List<Recognition> getRecognitions() {
    return _recognitions == null ? [] : _recognitions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          YOLOCameraWidget(setRecognitions),
          Stack(
            children: getRecognitions()
                .map(
                  (recognition) => new RecognitionWidget(recognition),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
