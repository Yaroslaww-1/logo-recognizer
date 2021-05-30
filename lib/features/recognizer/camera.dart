import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;

import 'package:logo_recognizer/features/recognizer/recognition.dart';

typedef void SetRecognitions(
    List<Recognition> recognitions, int imageHeight, int imageWidth);

class CameraWidget extends StatefulWidget {
  final SetRecognitions setRecognitions;

  CameraWidget(this.setRecognitions);

  @override
  _CameraWidgetState createState() => new _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget>
    with WidgetsBindingObserver {
  CameraController _controller;

  bool _isDetecting = false;
  void setIsDetecting(bool isDetecting) {
    setState(() {
      _isDetecting = isDetecting;
    });
  }

  List<CameraDescription> _cameras;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (_controller == null || !_controller.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (_controller != null) {
        onNewCameraSelected(_controller.description);
      }
    }
  }

  void onNewCameraSelected(CameraDescription cameraDescription) {
    print("onNewCameraSelected");
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    () async {
      await _initializeCameras();
      await _initializeImageStreamProcessing();
    }();
  }

  Future<void> _initializeCameras() async {
    _cameras = await availableCameras();

    if (_cameras == null || _cameras.length == 0) {
      print('No camera is found');
      return;
    }
  }

  Future<void> _initializeImageStreamProcessing() async {
    _controller = new CameraController(
      _cameras[0],
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await _controller.initialize();

    if (!mounted) {
      return;
    }

    _controller.startImageStream(_processImageStream);
  }

  Future<void> _processImageStream(CameraImage img) async {
    if (_isDetecting == true) {
      return;
    }

    setIsDetecting(true);

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
        .map((recognition) => new Recognition(
            recognition['rect']['x'],
            recognition['rect']['y'],
            recognition['rect']['w'],
            recognition['rect']['h'],
            recognition['detectedClass']))
        .toList();

    print(recognitions);

    widget.setRecognitions(_recognitions, img.height, img.width);

    setIsDetecting(false);
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller.value.isInitialized) {
      return Container();
    }

    var tmp = MediaQuery.of(context).size;
    var screenH = math.max(tmp.height, tmp.width);
    var screenW = math.min(tmp.height, tmp.width);
    tmp = _controller.value.previewSize;
    var previewH = math.max(tmp.height, tmp.width);
    var previewW = math.min(tmp.height, tmp.width);
    var screenRatio = screenH / screenW;
    var previewRatio = previewH / previewW;

    return OverflowBox(
      maxHeight:
          screenRatio > previewRatio ? screenH : screenW / previewW * previewH,
      maxWidth:
          screenRatio > previewRatio ? screenH / previewH * previewW : screenW,
      child: CameraPreview(_controller),
    );
  }
}
