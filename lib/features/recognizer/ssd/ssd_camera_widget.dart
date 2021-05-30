import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';

import 'package:logo_recognizer/features/recognizer/camera.dart';
import 'package:logo_recognizer/features/recognizer/recognition.dart';

typedef void SetRecognitions(
  List<Recognition> recognitions,
  int imageHeight,
  int imageWidth,
);

class SSDCameraWidget extends StatefulWidget {
  final SetRecognitions setRecognitions;

  SSDCameraWidget(this.setRecognitions);

  @override
  _SSDCameraWidgetState createState() => new _SSDCameraWidgetState();
}

class _SSDCameraWidgetState extends State<SSDCameraWidget>
    with WidgetsBindingObserver {
  Future<void> _processImageStream(CameraImage img) async {
    var recognitions = await Tflite.detectObjectOnFrame(
      bytesList: img.planes.map((plane) {
        return plane.bytes;
      }).toList(),
      model: "SSDMobileNet",
      imageHeight: img.height,
      imageWidth: img.width,
      imageMean: 127.5,
      imageStd: 127.5,
      numResultsPerClass: 1,
      threshold: 0.5,
    );

    var _recognitions = recognitions
        .map(
          (recognition) => new Recognition(
            recognition['detectedClass'],
            recognition["confidenceInClass"],
            new Rect.fromLTWH(
              recognition['rect']['x'],
              recognition['rect']['y'],
              recognition['rect']['w'],
              recognition['rect']['h'],
            ),
          ),
        )
        .toList();

    widget.setRecognitions(_recognitions, img.height, img.width);
  }

  @override
  Widget build(BuildContext context) {
    return CameraWidget(_processImageStream);
  }
}
