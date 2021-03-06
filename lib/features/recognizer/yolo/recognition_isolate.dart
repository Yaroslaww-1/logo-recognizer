import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as imageLib;
import 'package:tflite_flutter/tflite_flutter.dart';

import 'package:logo_recognizer/features/recognizer/yolo/classifier.dart';

typedef convert_func = Pointer<Uint32> Function(
    Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>, Int32, Int32, Int32, Int32);
typedef Convert = Pointer<Uint32> Function(
    Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>, int, int, int, int);

class RecognitionIsolate {
  static const String DEBUG_NAME = "RecognitionIsolate";

  // ignore: unused_field
  Isolate _isolate;
  ReceivePort _receivePort = ReceivePort();
  SendPort _sendPort;

  SendPort get sendPort => _sendPort;

  void start() async {
    _isolate = await Isolate.spawn<SendPort>(
      entryPoint,
      _receivePort.sendPort,
      debugName: DEBUG_NAME,
    );

    _sendPort = await _receivePort.first;
  }

  static void entryPoint(SendPort sendPort) async {
    final port = ReceivePort();
    final DynamicLibrary convertImageLib = Platform.isAndroid
        ? DynamicLibrary.open("libconvertImage.so")
        : DynamicLibrary.process();
    Convert conv = convertImageLib
        .lookup<NativeFunction<convert_func>>('convertImage')
        .asFunction<Convert>();
    sendPort.send(port.sendPort);

    await for (final RecognitionIsolateData isolateData in port) {
      if (isolateData != null) {
        var classifier = ClassifierYolo(
          interpreter: Interpreter.fromAddress(isolateData.interpreterAddress),
          labels: isolateData.labels,
        );
        imageLib.Image image;
        if (Platform.isAndroid) {
          Pointer<Uint8> p =
              calloc.allocate(isolateData.cameraImage.planes[0].bytes.length);
          Pointer<Uint8> p1 =
              calloc.allocate(isolateData.cameraImage.planes[1].bytes.length);
          Pointer<Uint8> p2 =
              calloc.allocate(isolateData.cameraImage.planes[2].bytes.length);

          Uint8List pointerList =
              p.asTypedList(isolateData.cameraImage.planes[0].bytes.length);
          Uint8List pointerList1 =
              p1.asTypedList(isolateData.cameraImage.planes[1].bytes.length);
          Uint8List pointerList2 =
              p2.asTypedList(isolateData.cameraImage.planes[2].bytes.length);
          pointerList.setRange(
              0,
              isolateData.cameraImage.planes[0].bytes.length,
              isolateData.cameraImage.planes[0].bytes);
          pointerList1.setRange(
              0,
              isolateData.cameraImage.planes[1].bytes.length,
              isolateData.cameraImage.planes[1].bytes);
          pointerList2.setRange(
              0,
              isolateData.cameraImage.planes[2].bytes.length,
              isolateData.cameraImage.planes[2].bytes);

          // Call the convertImage function and convert the YUV to RGB
          Pointer<Uint32> imgP = conv(
              p,
              p1,
              p2,
              isolateData.cameraImage.planes[1].bytesPerRow,
              isolateData.cameraImage.planes[1].bytesPerPixel,
              isolateData.cameraImage.planes[0].bytesPerRow,
              isolateData.cameraImage.height);

          List imgData = imgP.asTypedList(
              (isolateData.cameraImage.planes[0].bytesPerRow *
                  isolateData.cameraImage.height));

          image = imageLib.Image.fromBytes(isolateData.cameraImage.height,
              isolateData.cameraImage.width, imgData);

          calloc.free(p);
          calloc.free(p1);
          calloc.free(p2);
          calloc.free(imgP);
        } else if (Platform.isIOS) {
          image = imageLib.Image.fromBytes(
            isolateData.cameraImage.planes[0].bytesPerRow,
            isolateData.cameraImage.height,
            isolateData.cameraImage.planes[0].bytes,
            format: imageLib.Format.rgb,
          );
        }

        Map<String, dynamic> results = classifier.predict(image);

        isolateData.responsePort.send(results);
      }
    }
  }
}

class RecognitionIsolateData {
  CameraImage cameraImage;
  int interpreterAddress;
  List<String> labels;
  SendPort responsePort;

  RecognitionIsolateData(
    this.cameraImage,
    this.interpreterAddress,
    this.labels,
  );
}
