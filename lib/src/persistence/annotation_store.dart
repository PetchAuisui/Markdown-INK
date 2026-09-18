import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../ink/ink_stroke.dart';
import '../sample_markdown.dart';

class StoredDocument {
  const StoredDocument({
    required this.name,
    required this.markdown,
    required this.strokes,
  });

  final String name;
  final String markdown;
  final List<InkStroke> strokes;
}

class AnnotationStore {
  static const _documentNameKey = 'document.name';
  static const _documentContentKey = 'document.markdown';

  Future<StoredDocument> loadLastDocument() async {
    final preferences = await SharedPreferences.getInstance();
    final name = preferences.getString(_documentNameKey) ?? 'lecture-notes.md';
    final markdown =
        preferences.getString(_documentContentKey) ?? sampleMarkdown;
    return StoredDocument(
      name: name,
      markdown: markdown,
      strokes: _decodeStrokes(preferences.getString(_inkKey(name))),
    );
  }

  Future<List<InkStroke>> openDocument(String name, String markdown) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_documentNameKey, name);
    await preferences.setString(_documentContentKey, markdown);
    return _decodeStrokes(preferences.getString(_inkKey(name)));
  }

  Future<void> saveInk(String documentName, List<InkStroke> strokes) async {
    final preferences = await SharedPreferences.getInstance();
    final json = jsonEncode(strokes.map((stroke) => stroke.toJson()).toList());
    await preferences.setString(_inkKey(documentName), json);
  }

  String _inkKey(String documentName) {
    final safeName = documentName.replaceAll(RegExp(r'[^a-zA-Z0-9_.-]'), '_');
    return 'ink.$safeName.json';
  }

  List<InkStroke> _decodeStrokes(String? source) {
    if (source == null || source.isEmpty) return [];
    try {
      return (jsonDecode(source) as List)
          .map((stroke) => InkStroke.fromJson(stroke as Map<String, Object?>))
          .toList();
    } on FormatException {
      return [];
    }
  }
}
