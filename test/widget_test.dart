import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown_ink_annotation/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows the Markdown document and ink controls', (tester) async {
    await tester.pumpWidget(const MarkdownInkApp());
    await tester.pumpAndSettle();

    expect(find.text('Markdown Ink'), findsOneWidget);
    expect(find.text('lecture-notes.md'), findsOneWidget);
    expect(find.text('Pen'), findsOneWidget);
    expect(find.text('Eraser'), findsOneWidget);
    expect(find.byIcon(Icons.folder_open_outlined), findsOneWidget);
    expect(find.byTooltip('Insert image'), findsOneWidget);

    await tester.tap(find.text('Text'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), '# Edited note');
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.text('Draw'));
    await tester.pumpAndSettle();
    expect(find.text('Edited note'), findsOneWidget);

    await tester.drag(find.byType(ListView).last, const Offset(-600, 0));
    await tester.pumpAndSettle();
    expect(find.text('Touch draws'), findsOneWidget);
  });

  testWidgets('renders an embedded Markdown image', (tester) async {
    SharedPreferences.setMockInitialValues({
      'document.name': 'image-note.md',
      'document.markdown':
          '# Image note\n\n![dot](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAusB9Wl8nHkAAAAASUVORK5CYII=)',
    });
    await tester.pumpWidget(const MarkdownInkApp());
    await tester.pumpAndSettle();

    expect(find.text('image-note.md'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });
}
