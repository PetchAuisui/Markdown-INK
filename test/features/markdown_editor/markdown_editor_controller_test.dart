import 'package:flutter_test/flutter_test.dart';
import 'package:markdown_layers/features/markdown_editor/domain/markdown_document.dart';
import 'package:markdown_layers/features/markdown_editor/domain/markdown_document_repository.dart';
import 'package:markdown_layers/features/markdown_editor/presentation/markdown_editor_controller.dart';

void main() {
  group('MarkdownEditorController', () {
    test('marks changed content as dirty', () {
      final controller = MarkdownEditorController(_FakeRepository());

      controller.updateContent('# Changed');

      expect(controller.document.content, '# Changed');
      expect(controller.isDirty, isTrue);
    });

    test('opens a selected document', () async {
      final repository = _FakeRepository(
        opened: const MarkdownDocument(
          name: 'notes.md',
          content: '# Notes',
          path: '/notes.md',
        ),
      );
      final controller = MarkdownEditorController(repository);

      await controller.open();

      expect(controller.document.name, 'notes.md');
      expect(controller.document.content, '# Notes');
      expect(controller.isDirty, isFalse);
    });

    test('clears dirty state after saving', () async {
      final repository = _FakeRepository();
      final controller = MarkdownEditorController(repository);
      controller.updateContent('# Changed');

      final didSave = await controller.save();

      expect(didSave, isTrue);
      expect(controller.isDirty, isFalse);
      expect(repository.savedContent, '# Changed');
    });
  });
}

class _FakeRepository implements MarkdownDocumentRepository {
  _FakeRepository({this.opened});

  final MarkdownDocument? opened;
  String? savedContent;

  @override
  Future<MarkdownDocument?> open() async => opened;

  @override
  Future<MarkdownDocument?> save(
    MarkdownDocument document, {
    required bool saveAs,
  }) async {
    savedContent = document.content;
    return document.copyWith(path: '/saved.md');
  }
}
