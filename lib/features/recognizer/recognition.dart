import 'package:flutter/cupertino.dart';

class Recognition implements Comparable<Recognition> {
  final String label;
  final double confidence;
  final Rect location;

  Recognition(this.label, this.confidence, [this.location]);

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
