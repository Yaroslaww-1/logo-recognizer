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
    var screenH = CameraConfig.screenSize.height;
    var screenW = CameraConfig.screenSize.width;
    var previewH = CameraConfig.inputImageSize.height;
    var previewW = CameraConfig.inputImageSize.width;

    var _x = recognition.location.left;
    var _w = recognition.location.width;
    var _y = recognition.location.top;
    var _h = recognition.location.height;
    var scaleW, scaleH, x, y, w, h;

    scaleW = screenH / previewH * previewW;
    scaleH = screenH;
    var difW = (scaleW - screenW) / scaleW;
    x = (_x - difW / 2) * scaleW;
    w = _w * scaleW;
    if (_x < difW / 2) w -= (difW / 2 - _x) * scaleW;
    y = _y * scaleH;
    h = _h * scaleH;

    return new Recognition(
      recognition.label,
      recognition.confidence,
      new Rect.fromLTWH(
        x / previewW - 80,
        y / previewH,
        w / previewW,
        h / previewH,
      ),
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
