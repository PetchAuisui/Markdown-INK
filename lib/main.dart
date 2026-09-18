import 'package:flutter/material.dart';

import 'src/annotation_page.dart';

void main() => runApp(const MarkdownInkApp());

class MarkdownInkApp extends StatelessWidget {
  const MarkdownInkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Markdown Ink',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF315CFF)),
        scaffoldBackgroundColor: const Color(0xFFF2F4F8),
        useMaterial3: true,
      ),
      home: const AnnotationPage(),
    );
  }
}
