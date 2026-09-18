import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'ink/ink_canvas.dart';
import 'ink/ink_controller.dart';
import 'ink/ink_toolbar.dart';
import 'sample_markdown.dart';

class AnnotationPage extends StatefulWidget {
  const AnnotationPage({super.key});

  @override
  State<AnnotationPage> createState() => _AnnotationPageState();
}

class _AnnotationPageState extends State<AnnotationPage> {
  static const _documentHeight = 1500.0;
  final _inkController = InkController();
  bool _drawWithTouch = false;

  @override
  void dispose() {
    _inkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Markdown Ink'),
            Text('lecture-notes.md', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Card(
            margin: const EdgeInsets.all(16),
            clipBehavior: Clip.antiAlias,
            child: ScrollConfiguration(
              behavior: const _DocumentScrollBehavior(),
              child: SingleChildScrollView(
                physics: _drawWithTouch
                    ? const NeverScrollableScrollPhysics()
                    : const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: _documentHeight),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(48, 40, 48, 120),
                        child: MarkdownBody(
                          data: sampleMarkdown,
                          selectable: true,
                          styleSheet: MarkdownStyleSheet(
                            h1: Theme.of(context).textTheme.headlineLarge,
                            h2: Theme.of(context).textTheme.headlineMedium,
                            p: Theme.of(
                              context,
                            ).textTheme.bodyLarge?.copyWith(height: 1.65),
                            blockquoteDecoration: BoxDecoration(
                              color: const Color(0xFFE9EEFF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: InkCanvas(
                          controller: _inkController,
                          drawWithTouch: _drawWithTouch,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: InkToolbar(
        controller: _inkController,
        drawWithTouch: _drawWithTouch,
        onDrawWithTouchChanged: (value) {
          setState(() => _drawWithTouch = value);
        },
      ),
    );
  }
}

class _DocumentScrollBehavior extends MaterialScrollBehavior {
  const _DocumentScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };
}
