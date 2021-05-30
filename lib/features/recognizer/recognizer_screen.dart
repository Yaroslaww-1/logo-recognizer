import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';

import 'package:logo_recognizer/features/recognizer/recognition.dart';
import 'package:logo_recognizer/features/recognizer/recognitions_widget.dart';
import 'camera.dart';
import 'dart:math' as math;

class RecognizerScreen extends StatefulWidget {
  RecognizerScreen();

  @override
  _RecognizerScreenState createState() => new _RecognizerScreenState();
}

class _RecognizerScreenState extends State<RecognizerScreen> {
  List<Recognition> _recognitions;
  int _imageHeight = 0;
  int _imageWidth = 0;

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    await Tflite.loadModel(
      model: "assets/ssd_mobilenet_logodet.tflite",
      labels: "assets/ssd_mobilenet_logodet_classes.txt",
    );
  }

  void setRecognitions(
      List<Recognition> recognitions, int imageHeight, int imageWidth) {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CameraWidget(setRecognitions),
          RecognitionsWidget(
            _recognitions == null ? [] : _recognitions,
            math.max(_imageHeight, _imageWidth),
            math.min(_imageHeight, _imageWidth),
          ),
        ],
      ),
    );
  }
}
