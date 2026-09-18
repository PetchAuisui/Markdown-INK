import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'sample_markdown.dart';

class AnnotationPage extends StatelessWidget {
  const AnnotationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Markdown Ink'),
            Text('lecture-notes.md', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Card(
            margin: const EdgeInsets.all(16),
            clipBehavior: Clip.antiAlias,
            child: Markdown(
              data: sampleMarkdown,
              padding: const EdgeInsets.fromLTRB(48, 40, 48, 120),
              selectable: true,
              styleSheet: MarkdownStyleSheet(
                h1: Theme.of(context).textTheme.headlineLarge,
                h2: Theme.of(context).textTheme.headlineMedium,
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
        ),
      ),
    );
  }
}
