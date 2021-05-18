import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;

typedef void SetRegonitionsCallback(List<dynamic> list, int h, int w);

class RecognizerCameraWidget extends StatefulWidget {
  final SetRegonitionsCallback setRecognitions;

  RecognizerCameraWidget(this.setRecognitions);

  @override
  _RecognizerCameraWidgetState createState() =>
      new _RecognizerCameraWidgetState();
}

class _RecognizerCameraWidgetState extends State<RecognizerCameraWidget>
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
    super.dispose();
    _controller?.dispose();
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

    var recognitions = await Tflite.runModelOnFrame(
        bytesList: img.planes.map((plane) {
          return plane.bytes;
        }).toList(),
        imageHeight: img.height,
        imageWidth: img.width,
        imageMean: 127.5,
        imageStd: 127.5,
        numResults: 3,
        rotation: 0,
        threshold: 0.1);

    widget.setRecognitions(recognitions, img.height, img.width);

    setIsDetecting(false);
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller.value.isInitialized) {
      return Container();
    }

    return CameraPreview(_controller);
  }
}
