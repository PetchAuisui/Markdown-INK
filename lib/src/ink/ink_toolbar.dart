import 'package:flutter/material.dart';

import 'ink_controller.dart';

class InkToolbar extends StatelessWidget {
  const InkToolbar({
    required this.controller,
    required this.drawWithTouch,
    required this.onDrawWithTouchChanged,
    super.key,
  });

  final InkController controller;
  final bool drawWithTouch;
  final ValueChanged<bool> onDrawWithTouchChanged;

  static const _colors = [
    Color(0xFF2455E6),
    Color(0xFFE33B32),
    Color(0xFF171A21),
    Color(0xFF15945D),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Material(
          color: Theme.of(context).colorScheme.surface,
          elevation: 8,
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 72,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                children: [
                  SegmentedButton<InkTool>(
                    segments: const [
                      ButtonSegment(
                        value: InkTool.pen,
                        icon: Icon(Icons.draw_outlined),
                        label: Text('Pen'),
                      ),
                      ButtonSegment(
                        value: InkTool.eraser,
                        icon: Icon(Icons.auto_fix_normal_outlined),
                        label: Text('Eraser'),
                      ),
                    ],
                    selected: {controller.tool},
                    onSelectionChanged: (value) =>
                        controller.setTool(value.first),
                  ),
                  const VerticalDivider(width: 28),
                  ..._colors.map(
                    (color) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: IconButton(
                        tooltip: 'Ink color',
                        onPressed: () => controller.setColor(color),
                        icon: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: controller.color == color
                                ? Border.all(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    width: 3,
                                    strokeAlign: BorderSide.strokeAlignOutside,
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 130,
                    child: Slider(
                      value: controller.width,
                      min: 1.5,
                      max: 10,
                      divisions: 17,
                      label: controller.width.toStringAsFixed(1),
                      onChanged: controller.setWidth,
                    ),
                  ),
                  const VerticalDivider(width: 20),
                  IconButton(
                    tooltip: 'Undo',
                    onPressed: controller.canUndo ? controller.undo : null,
                    icon: const Icon(Icons.undo),
                  ),
                  IconButton(
                    tooltip: 'Redo',
                    onPressed: controller.canRedo ? controller.redo : null,
                    icon: const Icon(Icons.redo),
                  ),
                  IconButton(
                    tooltip: 'Clear all ink',
                    onPressed: controller.strokes.isEmpty
                        ? null
                        : controller.clear,
                    icon: const Icon(Icons.delete_outline),
                  ),
                  const VerticalDivider(width: 20),
                  FilterChip(
                    selected: drawWithTouch,
                    avatar: const Icon(Icons.touch_app_outlined, size: 18),
                    label: const Text('Touch draws'),
                    onSelected: onDrawWithTouchChanged,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
