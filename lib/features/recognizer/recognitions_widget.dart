import 'package:flutter/material.dart';

import 'package:logo_recognizer/features/recognizer/recognition.dart';
import 'package:logo_recognizer/features/recognizer/recognition_widget.dart';

class RecognitionsWidget extends StatelessWidget {
  final List<Recognition> recognitions;
  final int previewH;
  final int previewW;

  RecognitionsWidget(
    this.recognitions,
    this.previewH,
    this.previewW,
  );

  Recognition updateRecognitionPosition(
    Recognition recognition,
    double screenH,
    double screenW,
  ) {
    var _x = recognition.x;
    var _w = recognition.w;
    var _y = recognition.y;
    var _h = recognition.h;
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
      x,
      y,
      w,
      h,
      recognition.confidence,
      recognition.label,
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;

    return Stack(
      children: recognitions
          .map((recognition) => this.updateRecognitionPosition(
              recognition, screen.height, screen.width))
          .map((recognition) => new RecognitionWidget(recognition))
          .toList(),
    );
  }
}
