import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import '../domain/markdown_document.dart';
import '../domain/markdown_document_repository.dart';

class FileMarkdownDocumentRepository implements MarkdownDocumentRepository {
  const FileMarkdownDocumentRepository();

  @override
  Future<MarkdownDocument?> open() async {
    final pickedFile = await FilePicker.pickFile(
      dialogTitle: 'Open Markdown file',
      type: FileType.custom,
      allowedExtensions: const ['md', 'markdown', 'mdown', 'mkd'],
    );
    if (pickedFile == null) return null;

    final bytes = await pickedFile.readAsBytes();

    return MarkdownDocument(
      name: pickedFile.name,
      content: utf8.decode(bytes, allowMalformed: true),
      path: pickedFile.path,
    );
  }

  @override
  Future<MarkdownDocument?> save(
    MarkdownDocument document, {
    required bool saveAs,
  }) async {
    if (!saveAs && document.path != null) {
      await File(document.path!).writeAsString(document.content, flush: true);
      return document;
    }

    final bytes = Uint8List.fromList(utf8.encode(document.content));
    final uri = await FilePicker.saveFile(
      dialogTitle: 'Save Markdown file',
      fileName: _ensureMarkdownExtension(document.name),
      type: FileType.custom,
      allowedExtensions: const ['md'],
      bytes: bytes,
      mimeType: 'text/markdown',
    );
    if (uri == null) return null;

    final path = uri.scheme == 'file' ? uri.toFilePath() : null;
    return MarkdownDocument(
      name: path == null ? document.name : _fileName(path),
      content: document.content,
      path: path,
    );
  }

  String _ensureMarkdownExtension(String name) {
    return name.toLowerCase().endsWith('.md') ? name : '$name.md';
  }

  String _fileName(String path) {
    return Uri.file(path).pathSegments.last;
  }
}
