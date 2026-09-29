import 'markdown_document.dart';

abstract interface class MarkdownDocumentRepository {
  Future<MarkdownDocument?> open();

  Future<MarkdownDocument?> save(
    MarkdownDocument document, {
    required bool saveAs,
  });
}
