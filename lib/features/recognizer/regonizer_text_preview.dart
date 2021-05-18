import 'package:flutter/material.dart';

class RecognizerTextPreview extends StatelessWidget {
  final List<dynamic> results;
  final int previewH;
  final int previewW;
  final double screenH;
  final double screenW;

  RecognizerTextPreview(
    this.results,
    this.previewH,
    this.previewW,
    this.screenH,
    this.screenW,
  );

  String getPredictionResultText(dynamic res) {
    return "${res["label"]}: ${(res["confidence"] * 100).toStringAsFixed(0)}%";
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: RotatedBox(
        quarterTurns: 0,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(520.0, 80.0, .0, 0.0),
          children: results != null
              ? results.map(
                  (res) {
                    return Text(
                      getPredictionResultText(res),
                      style: TextStyle(
                        color: Color.fromRGBO(37, 213, 253, 1.0),
                        fontSize: 18.0,
                      ),
                    );
                  },
                ).toList()
              : [],
        ),
      ),
    );
  }
}
