import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import 'package:logo_recognizer/features/recognizer/camera_config.dart';

typedef Future<void> ProcessImage(CameraImage cameraImage);

class CameraWidget extends StatefulWidget {
  final ProcessImage processImage;

  CameraWidget(this.processImage);

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

      Size previewSize = _controller.value.previewSize;
      previewSize = new Size(
        math.min(previewSize.height, previewSize.width),
        math.max(previewSize.height, previewSize.width),
      );

      print(previewSize);

      /// previewSize is size of raw input image to the model
      CameraConfig.inputImageSize = previewSize;

      // the display width of image on screen is
      // same as screenWidth while maintaining the aspectRatio
      Size screenSize = MediaQuery.of(context).size;
      CameraConfig.screenSize = screenSize;

      // if (Platform.isAndroid) {
      //   // On Android Platform image is initially rotated by 90 degrees
      //   // due to the Flutter Camera plugin
      //   CameraConfig.ratio = screenSize.width / previewSize.height;
      // } else {
      //   // For iOS
      //   CameraConfig.ratio = screenSize.width / previewSize.width;
      // }
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

    await widget.processImage(img);

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
