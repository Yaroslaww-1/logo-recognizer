import 'dart:isolate';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'package:logo_recognizer/features/recognizer/camera.dart';
import 'package:logo_recognizer/features/recognizer/recognition.dart';
import 'package:logo_recognizer/features/recognizer/yolo/classifier.dart';
import 'package:logo_recognizer/features/recognizer/yolo/recognition_isolate.dart';

typedef void SetRecognitions(
  List<Recognition> recognitions,
  int imageHeight,
  int imageWidth,
);

class YOLOCameraWidget extends StatefulWidget {
  final SetRecognitions setRecognitions;

  const YOLOCameraWidget(this.setRecognitions);

  @override
  _YOLOCameraWidgetState createState() => _YOLOCameraWidgetState();
}

class _YOLOCameraWidgetState extends State<YOLOCameraWidget>
    with WidgetsBindingObserver {
  ClassifierYolo classifier;
  RecognitionIsolate isolate;

  @override
  void initState() {
    super.initState();
    start();
  }

  void start() {
    WidgetsBinding.instance.addObserver(this);

    classifier = ClassifierYolo();

    isolate = RecognitionIsolate();
    isolate.start();
  }

  /// Callback to receive each frame [CameraImage] perform inference on it
  Future<void> _processImageStream(CameraImage cameraImage) async {
    if (classifier.interpreter != null && classifier.labels != null) {
      var isolateData = RecognitionIsolateData(
        cameraImage,
        classifier.interpreter.address,
        classifier.labels,
      );

      // We could have simply used the compute method as well however
      // it would be as in-efficient as we need to continuously passing data
      // to another isolate.

      /// perform inference in separate isolate
      Map<String, dynamic> inferenceResults = await inference(isolateData);

      // pass results to HomeView
      widget.setRecognitions(
        inferenceResults["recognitions"],
        cameraImage.height,
        cameraImage.width,
      );
    }
  }

  /// Runs inference in another isolate
  Future<Map<String, dynamic>> inference(
    RecognitionIsolateData isolateData,
  ) async {
    ReceivePort responsePort = ReceivePort();
    isolate.sendPort.send(isolateData..responsePort = responsePort.sendPort);
    var results = await responsePort.first;
    return results;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CameraWidget(_processImageStream);
  }
}
