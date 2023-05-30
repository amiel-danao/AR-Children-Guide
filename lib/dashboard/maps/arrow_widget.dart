import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' show radians;

import 'arrow_painter.dart';

class ArrowWidget extends StatelessWidget {
  final double direction;

  const ArrowWidget(this.direction, {super.key});

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: FractionalOffset.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, -0.007)
        ..rotateX(radians(50))
        ..rotateZ(radians(-direction)),
      child: CustomPaint(
        size: Size(50, 120),
        painter: ArrowPainter(),
      ),
    );
  }
}
