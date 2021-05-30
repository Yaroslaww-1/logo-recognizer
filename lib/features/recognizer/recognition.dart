import 'dart:math';
import 'package:flutter/cupertino.dart';

import 'camera_config.dart';

class Recognition implements Comparable<Recognition> {
  final String label;
  final double confidence;
  final Rect location;

  Recognition(this.label, this.confidence, [this.location]);

  /// Returns bounding box rectangle corresponding to the
  /// displayed image on screen
  ///
  /// This is the actual location where rectangle is rendered on
  /// the screen
  Rect get renderLocation {
    // ratioX = screenWidth / imageInputWidth
    // ratioY = ratioX if image fits screenWidth with aspectRatio = constant

    double ratioX = CameraConfig.ratio;
    double ratioY = ratioX;

    double transLeft = max(0.1, location.left * ratioX);
    double transTop = max(0.1, location.top * ratioY);
    double transWidth =
        min(location.width * ratioX, CameraConfig.actualPreviewSize.width);
    double transHeight =
        min(location.height * ratioY, CameraConfig.actualPreviewSize.height);

    Rect transformedRect =
        Rect.fromLTWH(transLeft, transTop, transWidth, transHeight);
    return transformedRect;
  }

  @override
  String toString() {
    return 'Recognition(label: $label, score: ${(confidence * 100).toStringAsPrecision(3)}, location: $location)';
  }

  @override
  int compareTo(Recognition other) {
    if (this.confidence == other.confidence) {
      return 0;
    } else if (this.confidence > other.confidence) {
      return -1;
    } else {
      return 1;
    }
  }
}
