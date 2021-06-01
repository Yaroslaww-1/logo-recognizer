import 'dart:math';
import 'dart:ui';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imageLib;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

import 'package:logo_recognizer/features/recognizer/recognition.dart';

class ClassifierYolo {
  Interpreter _interpreter;
  Interpreter get interpreter => _interpreter;

  final int numThreads = 4;
  final bool isNNAPI = false;
  final bool isGPU = true;

  List<String> _labels;
  List<String> get labels => _labels;

  static const String MODEL_FILE_NAME = "yolov4.tflite";
  static const String LABEL_FILE_NAME = "yolov4.txt";

  static const int INPUT_SIZE = 416;

  static const double THRESHOLD = 0.3;

  static double mNmsThresh = 0.5;

  ImageProcessor imageProcessor;

  int padSize;

  List<List<int>> _outputShapes;

  List<TfLiteType> _outputTypes;

  static const int NUM_RESULTS = 10;

  ClassifierYolo({
    Interpreter interpreter,
    List<String> labels,
  }) {
    loadModel(interpreter: interpreter);
    loadLabels(labels: labels);
  }

  void loadModel({Interpreter interpreter}) async {
    try {
      _interpreter = interpreter ??
          await Interpreter.fromAsset(
            MODEL_FILE_NAME,
            options: InterpreterOptions()..threads = numThreads,
          );

      var outputTensors = _interpreter.getOutputTensors();
      _outputShapes = [];
      _outputTypes = [];
      outputTensors.forEach((tensor) {
        _outputShapes.add(tensor.shape);
        _outputTypes.add(tensor.type);
      });
    } catch (e) {
      print("Error while creating interpreter: $e");
      throw Error();
    }
  }

  void loadLabels({List<String> labels}) async {
    try {
      _labels =
          labels ?? await FileUtil.loadLabels("assets/" + LABEL_FILE_NAME);
    } catch (e) {
      print("Error while loading labels: $e");
      throw Error();
    }
  }

  TensorImage getProcessedImage(TensorImage inputImage) {
    padSize = max(inputImage.height, inputImage.width);
    if (imageProcessor == null) {
      imageProcessor = ImageProcessorBuilder()
          .add(ResizeWithCropOrPadOp(padSize, padSize))
          .add(ResizeOp(INPUT_SIZE, INPUT_SIZE, ResizeMethod.NEAREST_NEIGHBOUR))
          .add(NormalizeOp(127.5, 127.5))
          .build();
    }
    inputImage = imageProcessor.process(inputImage);
    return inputImage;
  }

  List<Recognition> nms(
    List<Recognition> list,
  ) {
    List<Recognition> nmsList = <Recognition>[];

    for (int k = 0; k < _labels.length; k++) {
      // 1.find max confidence per class
      PriorityQueue<Recognition> pq = new HeapPriorityQueue<Recognition>();
      for (int i = 0; i < list.length; ++i) {
        if (list[i].label == _labels[k]) {
          pq.add(list[i]);
        }
      }

      // 2.do non maximum suppression
      while (pq.length > 0) {
        List<Recognition> detections = pq.toList();
        Recognition max = detections[0];
        nmsList.add(max);
        pq.clear();
        for (int j = 1; j < detections.length; j++) {
          Recognition detection = detections[j];
          Rect b = detection.location;
          if (boxIou(max.location, b) < mNmsThresh) {
            pq.add(detection);
          }
        }
      }
    }

    return nmsList;
  }

  double boxIou(Rect a, Rect b) {
    return boxIntersection(a, b) / boxUnion(a, b);
  }

  double boxIntersection(Rect a, Rect b) {
    double w = overlap((a.left + a.right) / 2, a.right - a.left,
        (b.left + b.right) / 2, b.right - b.left);
    double h = overlap((a.top + a.bottom) / 2, a.bottom - a.top,
        (b.top + b.bottom) / 2, b.bottom - b.top);
    if ((w < 0) || (h < 0)) {
      return 0;
    }
    double area = (w * h);
    return area;
  }

  double boxUnion(Rect a, Rect b) {
    double i = boxIntersection(a, b);
    double u = ((((a.right - a.left) * (a.bottom - a.top)) +
            ((b.right - b.left) * (b.bottom - b.top))) -
        i);
    return u;
  }

  double overlap(double x1, double w1, double x2, double w2) {
    double l1 = (x1 - (w1 / 2));
    double l2 = (x2 - (w2 / 2));
    double left = ((l1 > l2) ? l1 : l2);
    double r1 = (x1 + (w1 / 2));
    double r2 = (x2 + (w2 / 2));
    double right = ((r1 < r2) ? r1 : r2);
    return right - left;
  }

  Map<String, dynamic> predict(imageLib.Image image) {
    if (_interpreter == null) {
      return null;
    }

    TensorImage inputImage = TensorImage(TfLiteType.float32);
    inputImage.loadImage(image);

    inputImage = getProcessedImage(inputImage);

    TensorBuffer outputLocations = TensorBufferFloat(_outputShapes[0]);

    List<List<List<double>>> outputClassScores = new List.generate(
        _outputShapes[1][0],
        (_) => new List.generate(_outputShapes[1][1],
            (_) => new List.filled(_outputShapes[1][2], 0.0),
            growable: false),
        growable: false);

    List<Object> inputs = [inputImage.buffer];

    Map<int, Object> outputs = {
      0: outputLocations.buffer,
      1: outputClassScores,
    };

    _interpreter.runForMultipleInputs(inputs, outputs);

    List<Rect> locations = BoundingBoxUtils.convert(
      tensor: outputLocations,
      boundingBoxAxis: 2,
      boundingBoxType: BoundingBoxType.CENTER,
      coordinateType: CoordinateType.PIXEL,
      height: INPUT_SIZE,
      width: INPUT_SIZE,
    );

    List<Recognition> recognitions = [];

    var gridWidth = _outputShapes[0][1];

    for (int i = 0; i < gridWidth; i++) {
      var maxClassScore = 0.00;
      var labelIndex = -1;

      for (int c = 0; c < _labels.length; c++) {
        // output[0][i][c] is the confidence score of c class
        if (outputClassScores[0][i][c] > maxClassScore) {
          labelIndex = c;
          maxClassScore = outputClassScores[0][i][c];
        }
      }

      var score = maxClassScore;

      var label;
      if (labelIndex != -1) {
        label = _labels.elementAt(labelIndex);
      } else {
        label = null;
      }

      if (score > THRESHOLD) {
        Rect rectAti = Rect.fromLTRB(
            max(0, locations[i].left),
            max(0, locations[i].top),
            min(INPUT_SIZE + 0.0, locations[i].right),
            min(INPUT_SIZE + 0.0, locations[i].bottom));

        // Gets the coordinates based on the original image if anything was done to it.
        Rect transformedRect = imageProcessor.inverseTransformRect(
          rectAti,
          image.height,
          image.width,
        );

        recognitions.add(
          Recognition(label, score, transformedRect),
        );
      }
    }
    List<Recognition> recognitionsNMS = nms(recognitions);

    return {
      "recognitions": recognitionsNMS,
    };
  }
}
