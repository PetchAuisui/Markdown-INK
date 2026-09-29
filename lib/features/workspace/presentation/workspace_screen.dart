import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../../markdown_editor/data/file_markdown_document_repository.dart';
import '../../markdown_editor/domain/markdown_document_repository.dart';
import '../../markdown_editor/presentation/markdown_editor_controller.dart';

enum WorkspaceMode { edit, preview }

class WorkspaceScreen extends StatefulWidget {
  const WorkspaceScreen({super.key, this.repository});

  final MarkdownDocumentRepository? repository;

  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  late final MarkdownEditorController _controller;
  late final TextEditingController _textController;
  WorkspaceMode _mode = WorkspaceMode.edit;

  @override
  void initState() {
    super.initState();
    _controller = MarkdownEditorController(
      widget.repository ?? const FileMarkdownDocumentRepository(),
    );
    _textController = TextEditingController(text: _controller.document.content);
  }

  @override
  void dispose() {
    _textController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openDocument() async {
    if (!await _confirmDiscardChanges()) return;
    await _controller.open();
    if (!mounted) return;
    _textController.value = TextEditingValue(
      text: _controller.document.content,
      selection: TextSelection.collapsed(
        offset: _controller.document.content.length,
      ),
    );
    _showErrorIfNeeded();
  }

  Future<void> _saveDocument({bool saveAs = false}) async {
    final didSave = await _controller.save(saveAs: saveAs);
    if (!mounted) return;
    _showErrorIfNeeded();
    if (didSave) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Markdown saved')));
    }
  }

  Future<bool> _confirmDiscardChanges() async {
    if (!_controller.isDirty) return true;
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Discard unsaved changes?'),
            content: const Text(
              'Opening another file will replace your current edits.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Keep editing'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Discard'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showErrorIfNeeded() {
    final message = _controller.errorMessage;
    if (message == null) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    _controller.clearError();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            titleSpacing: 16,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _controller.document.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _controller.isDirty ? 'Unsaved changes' : 'All changes saved',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Open Markdown',
                onPressed: _controller.isBusy ? null : _openDocument,
                icon: const Icon(Icons.folder_open_outlined),
              ),
              IconButton(
                tooltip: 'Save',
                onPressed: _controller.isBusy ? null : _saveDocument,
                icon: const Icon(Icons.save_outlined),
              ),
              PopupMenuButton<_DocumentAction>(
                tooltip: 'More document actions',
                enabled: !_controller.isBusy,
                onSelected: (action) {
                  if (action == _DocumentAction.saveAs) {
                    _saveDocument(saveAs: true);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: _DocumentAction.saveAs,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.save_as_outlined),
                      title: Text('Save as'),
                    ),
                  ),
                ],
              ),
            ],
            bottom: _controller.isBusy
                ? const PreferredSize(
                    preferredSize: Size.fromHeight(3),
                    child: LinearProgressIndicator(minHeight: 3),
                  )
                : null,
          ),
          body: Column(
            children: [
              _ModePicker(
                mode: _mode,
                onChanged: (mode) => setState(() => _mode = mode),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: _mode == WorkspaceMode.edit
                      ? _EditorPane(
                          key: const ValueKey('editor'),
                          controller: _textController,
                          onChanged: _controller.updateContent,
                        )
                      : _PreviewPane(
                          key: const ValueKey('preview'),
                          markdown: _controller.document.content,
                        ),
                ),
              ),
              const _LayerBar(),
            ],
          ),
        );
      },
    );
  }
}

enum _DocumentAction { saveAs }

class _ModePicker extends StatelessWidget {
  const _ModePicker({required this.mode, required this.onChanged});

  final WorkspaceMode mode;
  final ValueChanged<WorkspaceMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: SizedBox(
        width: double.infinity,
        child: SegmentedButton<WorkspaceMode>(
          segments: const [
            ButtonSegment(
              value: WorkspaceMode.edit,
              icon: Icon(Icons.edit_outlined),
              label: Text('Edit'),
            ),
            ButtonSegment(
              value: WorkspaceMode.preview,
              icon: Icon(Icons.visibility_outlined),
              label: Text('Preview'),
            ),
          ],
          selected: {mode},
          onSelectionChanged: (selection) => onChanged(selection.first),
        ),
      ),
    );
  }
}

class _EditorPane extends StatelessWidget {
  const _EditorPane({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        expands: true,
        maxLines: null,
        minLines: null,
        textAlignVertical: TextAlignVertical.top,
        keyboardType: TextInputType.multiline,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(fontFamily: 'monospace', height: 1.45),
        decoration: const InputDecoration(
          hintText: 'Write Markdown…',
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }
}

class _PreviewPane extends StatelessWidget {
  const _PreviewPane({super.key, required this.markdown});

  final String markdown;

  @override
  Widget build(BuildContext context) {
    return Markdown(
      data: markdown,
      selectable: true,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
        p: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
      ),
    );
  }
}

class _LayerBar extends StatelessWidget {
  const _LayerBar();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            scrollDirection: Axis.horizontal,
            children: const [
              Chip(
                avatar: Icon(Icons.description_outlined, size: 18),
                label: Text('Markdown'),
              ),
              SizedBox(width: 8),
              Chip(
                avatar: Icon(Icons.draw_outlined, size: 18),
                label: Text('Annotations · Soon'),
              ),
              SizedBox(width: 8),
              Chip(
                avatar: Icon(Icons.image_outlined, size: 18),
                label: Text('Images · Soon'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
