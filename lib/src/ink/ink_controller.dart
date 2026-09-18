import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'ink_stroke.dart';

enum InkTool { pen, eraser }

class InkController extends ChangeNotifier {
  final List<InkStroke> _strokes = [];
  final List<List<InkStroke>> _undoStack = [];
  final List<List<InkStroke>> _redoStack = [];

  InkStroke? _activeStroke;

  List<InkStroke> get strokes => List.unmodifiable(_strokes);
  InkStroke? get activeStroke => _activeStroke;
  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  InkTool tool = InkTool.pen;
  Color color = const Color(0xFF2455E6);
  double width = 3.5;

  void setTool(InkTool value) {
    if (tool == value) return;
    tool = value;
    notifyListeners();
  }

  void setColor(Color value) {
    if (color == value) return;
    color = value;
    notifyListeners();
  }

  void setWidth(double value) {
    if (width == value) return;
    width = value;
    notifyListeners();
  }

  void beginStroke(Offset point, {double pressure = 1}) {
    _activeStroke = InkStroke(
      points: [InkPoint(point, pressure: pressure)],
      color: color,
      width: width,
    );
    notifyListeners();
  }

  void appendPoint(Offset point, {double pressure = 1}) {
    final active = _activeStroke;
    if (active == null) return;
    active.points.add(InkPoint(point, pressure: pressure));
    notifyListeners();
  }

  void endStroke() {
    final active = _activeStroke;
    if (active == null) return;
    _checkpoint();
    _strokes.add(active);
    _activeStroke = null;
    notifyListeners();
  }

  void cancelStroke() {
    _activeStroke = null;
    notifyListeners();
  }

  void eraseAt(Offset point, {double radius = 14}) {
    final hitIndex = _strokes.lastIndexWhere(
      (stroke) => stroke.points.any(
        (inkPoint) => (inkPoint.offset - point).distance <= radius,
      ),
    );
    if (hitIndex < 0) return;
    _checkpoint();
    _strokes.removeAt(hitIndex);
    notifyListeners();
  }

  void undo() {
    if (!canUndo) return;
    _redoStack.add(List.of(_strokes));
    _replaceStrokes(_undoStack.removeLast());
  }

  void redo() {
    if (!canRedo) return;
    _undoStack.add(List.of(_strokes));
    _replaceStrokes(_redoStack.removeLast());
  }

  void clear() {
    if (_strokes.isEmpty) return;
    _checkpoint();
    _strokes.clear();
    notifyListeners();
  }

  void loadStrokes(Iterable<InkStroke> strokes) {
    _strokes
      ..clear()
      ..addAll(strokes);
    _undoStack.clear();
    _redoStack.clear();
    _activeStroke = null;
    notifyListeners();
  }

  void _checkpoint() {
    _undoStack.add(List.of(_strokes));
    _redoStack.clear();
  }

  void _replaceStrokes(List<InkStroke> replacement) {
    _strokes
      ..clear()
      ..addAll(replacement);
    notifyListeners();
  }
}
