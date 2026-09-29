import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown_layers/app/app.dart';

void main() {
  testWidgets('shows the Markdown editor workspace', (tester) async {
    await tester.pumpWidget(const MarkdownLayersApp());

    expect(find.text('Untitled.md'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Preview'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Markdown'), findsOneWidget);
  });

  testWidgets('edits Markdown and renders the preview', (tester) async {
    await tester.pumpWidget(const MarkdownLayersApp());

    await tester.enterText(find.byType(TextField), '# Preview title');
    await tester.pump();
    expect(find.text('Unsaved changes'), findsOneWidget);

    await tester.tap(find.text('Preview'));
    await tester.pumpAndSettle();

    expect(find.text('Preview title'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
  });
}
