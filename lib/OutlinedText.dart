import 'package:flutter/material.dart';

class OutlinedText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color fillColor;
  final Color outlineColor;
  final double strokeWidth;

  const OutlinedText({
    required this.text,
    required this.fontSize,
    required this.fillColor,
    required this.outlineColor,
    this.strokeWidth = 3.0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..color = outlineColor,
          ),
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            color: fillColor,
          ),
        ),
      ],
    );
  }
}
