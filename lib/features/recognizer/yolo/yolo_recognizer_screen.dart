import 'dart:math';
import 'package:flutter/material.dart';

import 'package:logo_recognizer/features/recognizer/camera_config.dart';
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

  Recognition updateRecognitionPosition(
    Recognition recognition,
  ) {
    var screenW = CameraConfig.screenSize.width;
    var previewW = CameraConfig.inputImageSize.width;

    var _x = recognition.location.left;
    var _w = recognition.location.width;
    var _y = recognition.location.top;
    var _h = recognition.location.height;
    var x, y, w, h;

    var difW = previewW - screenW;
    x = _x - difW / 2;
    w = _w;
    y = _y;
    h = _h;

    return new Recognition(
      recognition.label,
      recognition.confidence,
      new Rect.fromLTWH(x, y, w, h),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          YOLOCameraWidget(setRecognitions),
          Stack(
            children: getRecognitions()
                .map(updateRecognitionPosition)
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
