import 'package:flutter_test/flutter_test.dart';
import 'package:markdown_layers/app/app.dart';

void main() {
  testWidgets('shows the workspace shell', (tester) async {
    await tester.pumpWidget(const MarkdownLayersApp());

    expect(find.text('Markdown Layers'), findsOneWidget);
    expect(find.text('Your layered Markdown workspace'), findsOneWidget);
  });
}
