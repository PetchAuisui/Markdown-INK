import 'dart:ui';

class InkPoint {
  const InkPoint(this.offset, {this.pressure = 1});

  final Offset offset;
  final double pressure;

  Map<String, Object> toJson() => {
    'x': offset.dx,
    'y': offset.dy,
    'pressure': pressure,
  };

  factory InkPoint.fromJson(Map<String, Object?> json) {
    return InkPoint(
      Offset((json['x'] as num).toDouble(), (json['y'] as num).toDouble()),
      pressure: (json['pressure'] as num?)?.toDouble() ?? 1,
    );
  }
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

  Map<String, Object> toJson() => {
    'points': points.map((point) => point.toJson()).toList(),
    'color': color.toARGB32(),
    'width': width,
  };

  factory InkStroke.fromJson(Map<String, Object?> json) {
    return InkStroke(
      points: (json['points'] as List)
          .map((point) => InkPoint.fromJson(point as Map<String, Object?>))
          .toList(),
      color: Color(json['color'] as int),
      width: (json['width'] as num).toDouble(),
    );
  }
}
