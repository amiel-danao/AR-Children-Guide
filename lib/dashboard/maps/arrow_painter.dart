import 'package:flutter/material.dart';

class ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final rectanglePath = Path();
    rectanglePath.moveTo(0, 0);
    rectanglePath.lineTo(size.width, 0);
    rectanglePath.lineTo(size.width, size.height);
    rectanglePath.lineTo(0, size.height);
    rectanglePath.close();
    canvas.drawPath(rectanglePath, paint);

    final path = Path();
    path.moveTo(size.width / 2, -size.height);
    path.lineTo(size.width + 10 * 1.2, 10);
    path.lineTo(0 - 10 * 1.2, 10);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
