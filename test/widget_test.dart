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

    await tester.drag(find.byType(ListView).last, const Offset(-600, 0));
    await tester.pumpAndSettle();
    expect(find.text('Touch draws'), findsOneWidget);
  });
}
