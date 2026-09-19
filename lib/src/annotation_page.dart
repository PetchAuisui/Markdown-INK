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
  final _editor = TextEditingController();
  bool _drawWithTouch = false;
  bool _textMode = false;
  String _documentName = 'lecture-notes.md';
  String _markdown = sampleMarkdown;
  Timer? _saveTimer;
  Timer? _markdownSaveTimer;

  @override
  void initState() {
    super.initState();
    _inkController.addListener(_scheduleInkSave);
    _editor.text = _markdown;
    _editor.addListener(_onMarkdownChanged);
    _loadLastDocument();
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _markdownSaveTimer?.cancel();
    _editor.removeListener(_onMarkdownChanged);
    _editor.dispose();
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
    _editor.text = document.markdown;
    _inkController.loadStrokes(document.strokes);
  }

  void _onMarkdownChanged() {
    if (_markdown == _editor.text) return;
    _markdown = _editor.text;
    _markdownSaveTimer?.cancel();
    _markdownSaveTimer = Timer(const Duration(milliseconds: 500), () {
      _store.saveMarkdown(_documentName, _editor.text);
    });
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
    _saveTimer?.cancel();
    _markdownSaveTimer?.cancel();
    await _store.saveInk(_documentName, _inkController.strokes);
    final strokes = await _store.openDocument(file.name, markdown);
    if (!mounted) return;
    setState(() {
      _documentName = file.name;
      _markdown = markdown;
    });
    _editor.text = markdown;
    _inkController.loadStrokes(strokes);
  }

  Future<void> _insertImage() async {
    if (!_textMode) setState(() => _textMode = true);
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['png', 'jpg', 'jpeg', 'gif', 'webp'],
      withData: true,
    );
    if (result == null || !mounted) return;
    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null) return;
    final extension = file.extension?.toLowerCase();
    final mime = switch (extension) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'gif' => 'image/gif',
      'webp' => 'image/webp',
      _ => 'image/png',
    };
    final alt = file.name.replaceAll(RegExp(r'[\\[\\]]'), '');
    final imageMarkdown = '![$alt](data:$mime;base64,${base64Encode(bytes)})';
    final selection = _editor.selection;
    final position = selection.isValid ? selection.start : _editor.text.length;
    final end = selection.isValid ? selection.end : position;
    final text = _editor.text;
    final insertion = '\n$imageMarkdown\n';
    _editor.value = TextEditingValue(
      text: text.replaceRange(position, end, insertion),
      selection: TextSelection.collapsed(offset: position + insertion.length),
    );
  }

  Widget _buildImage(MarkdownImageConfig config) {
    final uri = config.uri;
    final alt = config.alt;
    if (uri.scheme != 'data') return Text(alt ?? 'Image unavailable');
    try {
      final bytes = UriData.fromUri(uri).contentAsBytes();
      return Image.memory(
        bytes,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => Text(alt ?? 'Image unavailable'),
      );
    } on FormatException {
      return Text(alt ?? 'Image unavailable');
    }
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
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: true,
                icon: Icon(Icons.edit_note),
                label: Text('Text'),
              ),
              ButtonSegment(
                value: false,
                icon: Icon(Icons.draw_outlined),
                label: Text('Draw'),
              ),
            ],
            selected: {_textMode},
            onSelectionChanged: (selection) =>
                setState(() => _textMode = selection.first),
          ),
          IconButton(
            tooltip: 'Open Markdown file',
            onPressed: _pickMarkdown,
            icon: const Icon(Icons.folder_open_outlined),
          ),
          IconButton(
            tooltip: 'Insert image',
            onPressed: _insertImage,
            icon: const Icon(Icons.add_photo_alternate_outlined),
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
            child: _textMode
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: TextField(
                      controller: _editor,
                      autofocus: true,
                      expands: true,
                      maxLines: null,
                      textAlignVertical: TextAlignVertical.top,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 15,
                        height: 1.5,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Write Markdown here…',
                      ),
                    ),
                  )
                : ScrollConfiguration(
                    behavior: const _DocumentScrollBehavior(),
                    child: SingleChildScrollView(
                      physics: _drawWithTouch
                          ? const NeverScrollableScrollPhysics()
                          : const ClampingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: _documentHeight,
                        ),
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                48,
                                40,
                                48,
                                120,
                              ),
                              child: MarkdownBody(
                                data: _markdown,
                                sizedImageBuilder: _buildImage,
                                selectable: true,
                                styleSheet: MarkdownStyleSheet(
                                  h1: Theme.of(context).textTheme.headlineLarge,
                                  h2: Theme.of(
                                    context,
                                  ).textTheme.headlineMedium,
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
      bottomNavigationBar: _textMode
          ? null
          : InkToolbar(
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
