import 'package:flutter/cupertino.dart';

class ProgressBarView extends CustomPainter {
  final Color primaryColor;
  final double indicatorSize;

  ProgressBarView({
        required this.primaryColor,
        required this.indicatorSize,
        });


  @override
  void paint(Canvas canvas, Size size) {

    // draw a circular indicator
    canvas.drawCircle(
      const Offset(0, 0),
      indicatorSize / 2,
      _circlePainterFactory(primaryColor, 0),
    );
  }

  Paint _circlePainterFactory(Color color, double radius) => Paint()
    ..color = color
    ..strokeWidth = radius
    ..style = PaintingStyle.fill;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}