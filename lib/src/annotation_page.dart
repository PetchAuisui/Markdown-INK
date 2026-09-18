import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'ink/ink_canvas.dart';
import 'ink/ink_controller.dart';
import 'ink/ink_toolbar.dart';
import 'persistence/annotation_store.dart';
import 'sample_markdown.dart';

class AnnotationPage extends StatefulWidget {
  const AnnotationPage({super.key});

  @override
  State<AnnotationPage> createState() => _AnnotationPageState();
}

class _AnnotationPageState extends State<AnnotationPage> {
  static const _documentHeight = 1500.0;
  final _inkController = InkController();
  final _store = AnnotationStore();
  bool _drawWithTouch = false;
  String _documentName = 'lecture-notes.md';
  String _markdown = sampleMarkdown;
  Timer? _saveTimer;

  @override
  void initState() {
    super.initState();
    _inkController.addListener(_scheduleInkSave);
    _loadLastDocument();
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _inkController.removeListener(_scheduleInkSave);
    _inkController.dispose();
    super.dispose();
  }

  Future<void> _loadLastDocument() async {
    final document = await _store.loadLastDocument();
    if (!mounted) return;
    setState(() {
      _documentName = document.name;
      _markdown = document.markdown;
    });
    _inkController.loadStrokes(document.strokes);
  }

  Future<void> _pickMarkdown() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['md', 'markdown', 'txt'],
      withData: true,
    );
    if (result == null) return;
    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null || !mounted) return;
    final markdown = utf8.decode(bytes, allowMalformed: true);
    final strokes = await _store.openDocument(file.name, markdown);
    if (!mounted) return;
    setState(() {
      _documentName = file.name;
      _markdown = markdown;
    });
    _inkController.loadStrokes(strokes);
  }

  void _scheduleInkSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 600), () {
      _store.saveInk(_documentName, _inkController.strokes);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Markdown Ink'),
            Text(_documentName, style: const TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Open Markdown file',
            onPressed: _pickMarkdown,
            icon: const Icon(Icons.folder_open_outlined),
          ),
          const SizedBox(width: 8),
        ],
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
                          data: _markdown,
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
