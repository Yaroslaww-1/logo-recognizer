import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';

import 'package:logo_recognizer/features/recognizer/ssd/ssd_camera_widget.dart';
import 'package:logo_recognizer/features/recognizer/recognition_widget.dart';
import 'package:logo_recognizer/features/recognizer/camera_config.dart';
import 'package:logo_recognizer/features/recognizer/recognition.dart';

class SSDRecognizerScreen extends StatefulWidget {
  @override
  _SSDRecognizerScreenState createState() => new _SSDRecognizerScreenState();
}

class _SSDRecognizerScreenState extends State<SSDRecognizerScreen> {
  List<Recognition> _recognitions;

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  @override
  void dispose() {
    super.dispose();
    disposeModel();
  }

  Future<void> loadModel() async {
    await Tflite.loadModel(
      model: "assets/ssd_mobilenet_logodet.tflite",
      labels: "assets/ssd_mobilenet_logodet_classes.txt",
    );
  }

  Future<void> disposeModel() async {
    Timer(Duration(seconds: 1), () {
      Tflite.close();
    });
  }

  void setRecognitions(
      List<Recognition> recognitions, int imageHeight, int imageWidth) {
    print("SSD $recognitions");

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
    var difW = scaleW - screenW;
    x = _x * scaleW - difW / 2;
    w = _w * scaleW;
    y = _y * scaleH;
    h = _h * scaleH;

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
          SSDCameraWidget(setRecognitions),
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
