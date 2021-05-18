import 'package:flutter/material.dart';

class RecognizerTextPreview extends StatelessWidget {
  final List<dynamic> results;

  RecognizerTextPreview(
    this.results,
  );

  String getPredictionResultText(dynamic res) {
    var predictionResultText =
        "${res["label"]}: ${(res["confidence"] * 100).toStringAsFixed(0)}%";
    print(predictionResultText);
    return predictionResultText;
  }

  List<String> getPredictions() {
    if (results == null) {
      return [];
    }

    return results.map(getPredictionResultText).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: getPredictions().map(
        (String prediction) {
          return Text(
            prediction,
            style: TextStyle(
              color: Color.fromRGBO(37, 213, 253, 1.0),
              fontSize: 18.0,
            ),
          );
        },
      ).toList(),
    );
  }
}
