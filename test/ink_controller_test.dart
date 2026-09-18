import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:markdown_ink_annotation/src/ink/ink_controller.dart';
import 'package:markdown_ink_annotation/src/ink/ink_stroke.dart';

void main() {
  test('stroke lifecycle supports undo and redo', () {
    final controller = InkController();

    controller.beginStroke(const Offset(10, 20));
    controller.appendPoint(const Offset(30, 40));
    controller.endStroke();

    expect(controller.strokes, hasLength(1));
    expect(controller.canUndo, isTrue);

    controller.undo();
    expect(controller.strokes, isEmpty);
    expect(controller.canRedo, isTrue);

    controller.redo();
    expect(controller.strokes.single.points, hasLength(2));
  });

  test('ink stroke survives a JSON-compatible round trip', () {
    const original = InkStroke(
      points: [InkPoint(Offset(12.5, 42), pressure: 0.75)],
      color: Color(0xFF123456),
      width: 4.5,
    );

    final restored = InkStroke.fromJson(original.toJson());

    expect(restored.points.single.offset, const Offset(12.5, 42));
    expect(restored.points.single.pressure, 0.75);
    expect(restored.color, const Color(0xFF123456));
    expect(restored.width, 4.5);
  });
}
