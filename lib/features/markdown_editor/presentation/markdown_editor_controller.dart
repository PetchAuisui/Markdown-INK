import 'package:flutter/foundation.dart';

import '../domain/markdown_document.dart';
import '../domain/markdown_document_repository.dart';

const initialMarkdown = '''# Welcome to Markdown Layers

Open a Markdown file or start writing here.

## Built for layers

- Markdown content
- Drawing and highlight annotations (coming next)
- Images (coming next)
''';

class MarkdownEditorController extends ChangeNotifier {
  MarkdownEditorController(this._repository)
    : _document = const MarkdownDocument(
        name: 'Untitled.md',
        content: initialMarkdown,
      );

  final MarkdownDocumentRepository _repository;
  MarkdownDocument _document;
  bool _isBusy = false;
  bool _isDirty = false;
  String? _errorMessage;

  MarkdownDocument get document => _document;
  bool get isBusy => _isBusy;
  bool get isDirty => _isDirty;
  String? get errorMessage => _errorMessage;

  void updateContent(String content) {
    if (content == _document.content) return;
    _document = _document.copyWith(content: content);
    _isDirty = true;
    notifyListeners();
  }

  Future<void> open() async {
    await _run(() async {
      final opened = await _repository.open();
      if (opened == null) return;
      _document = opened;
      _isDirty = false;
    });
  }

  Future<bool> save({bool saveAs = false}) async {
    var didSave = false;
    await _run(() async {
      final saved = await _repository.save(_document, saveAs: saveAs);
      if (saved == null) return;
      _document = saved;
      _isDirty = false;
      didSave = true;
    });
    return didSave;
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _run(Future<void> Function() action) async {
    _isBusy = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await action();
    } on Object catch (error) {
      _errorMessage = 'Something went wrong: $error';
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }
}
