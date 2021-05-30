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
    await Tflite.close();
  }

  void setRecognitions(
      List<Recognition> recognitions, int imageHeight, int imageWidth) {
    print("SSD $recognitions");
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

    if (screenH / screenW > previewH / previewW) {
      scaleW = screenH / previewH * previewW;
      scaleH = screenH;
      var difW = (scaleW - screenW) / scaleW;
      x = (_x - difW / 2) * scaleW;
      w = _w * scaleW;
      if (_x < difW / 2) w -= (difW / 2 - _x) * scaleW;
      y = _y * scaleH;
      h = _h * scaleH;
    } else {
      scaleH = screenW / previewW * previewH;
      scaleW = screenW;
      var difH = (scaleH - screenH) / scaleH;
      x = _x * scaleW;
      w = _w * scaleW;
      y = (_y - difH / 2) * scaleH;
      h = _h * scaleH;
      if (_y < difH / 2) h -= (difH / 2 - _y) * scaleH;
    }

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
