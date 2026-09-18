import 'dart:ui';

class InkPoint {
  const InkPoint(this.offset, {this.pressure = 1});

  final Offset offset;
  final double pressure;
}

class InkStroke {
  const InkStroke({
    required this.points,
    required this.color,
    required this.width,
  });

  final List<InkPoint> points;
  final Color color;
  final double width;
}
