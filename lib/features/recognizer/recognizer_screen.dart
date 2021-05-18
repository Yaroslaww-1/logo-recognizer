import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;

import 'recognizer_camera_widget.dart';
import 'regonizer_text_preview.dart';

class RecognizerScreen extends StatefulWidget {
  RecognizerScreen();

  @override
  _RecognizerScreenState createState() => new _RecognizerScreenState();
}

class _RecognizerScreenState extends State<RecognizerScreen> {
  List<dynamic> _recognitions;
  int _imageHeight = 0;
  int _imageWidth = 0;

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    await Tflite.loadModel(
      model: "assets/mobilenet_v2_1.0_224.tflite",
      labels: "assets/labels.txt",
    );
  }

  void setRecognitions(
      List<dynamic> recognitions, int imageHeight, int imageWidth) {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;

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
        body: Stack(
          children: [
            RotatedBox(
              quarterTurns: -1,
              child: RecognizerCameraWidget(
                setRecognitions,
              ),
            ),
            RecognizerTextPreview(
              _recognitions == null ? [] : _recognitions,
              math.max(_imageHeight, _imageWidth),
              math.min(_imageHeight, _imageWidth),
              screen.height,
              screen.width,
            ),
          ],
        ),
      ),
    );
  }
}
