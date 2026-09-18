import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'ink_controller.dart';
import 'ink_stroke.dart';

class InkCanvas extends StatelessWidget {
  const InkCanvas({
    required this.controller,
    required this.drawWithTouch,
    super.key,
  });

  final InkController controller;
  final bool drawWithTouch;

  bool _accepts(PointerEvent event) {
    return event.kind == PointerDeviceKind.stylus ||
        event.kind == PointerDeviceKind.invertedStylus ||
        (drawWithTouch && event.kind == PointerDeviceKind.touch) ||
        (drawWithTouch && event.kind == PointerDeviceKind.mouse);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (event) {
            if (!_accepts(event)) return;
            if (controller.tool == InkTool.eraser ||
                event.kind == PointerDeviceKind.invertedStylus) {
              controller.eraseAt(event.localPosition);
            } else {
              controller.beginStroke(
                event.localPosition,
                pressure: event.pressure,
              );
            }
          },
          onPointerMove: (event) {
            if (!_accepts(event)) return;
            if (controller.tool == InkTool.eraser ||
                event.kind == PointerDeviceKind.invertedStylus) {
              controller.eraseAt(event.localPosition);
            } else {
              controller.appendPoint(
                event.localPosition,
                pressure: event.pressure,
              );
            }
          },
          onPointerUp: (event) => controller.endStroke(),
          onPointerCancel: (event) => controller.cancelStroke(),
          child: CustomPaint(
            painter: InkPainter(
              strokes: controller.strokes,
              activeStroke: controller.activeStroke,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }
}

class InkPainter extends CustomPainter {
  InkPainter({required this.strokes, this.activeStroke});

  final List<InkStroke> strokes;
  final InkStroke? activeStroke;

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in [...strokes, ?activeStroke]) {
      _paintStroke(canvas, stroke);
    }
  }

  void _paintStroke(Canvas canvas, InkStroke stroke) {
    if (stroke.points.isEmpty) return;
    final paint = Paint()
      ..color = stroke.color
      ..strokeWidth = stroke.width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    if (stroke.points.length == 1) {
      canvas.drawPoints(PointMode.points, [stroke.points.first.offset], paint);
      return;
    }

    final path = Path()
      ..moveTo(stroke.points.first.offset.dx, stroke.points.first.offset.dy);
    for (var i = 1; i < stroke.points.length; i++) {
      final previous = stroke.points[i - 1].offset;
      final current = stroke.points[i].offset;
      final midpoint = Offset(
        (previous.dx + current.dx) / 2,
        (previous.dy + current.dy) / 2,
      );
      path.quadraticBezierTo(
        previous.dx,
        previous.dy,
        midpoint.dx,
        midpoint.dy,
      );
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant InkPainter oldDelegate) => true;
}
