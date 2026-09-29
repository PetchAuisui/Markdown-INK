class MarkdownDocument {
  const MarkdownDocument({
    required this.name,
    required this.content,
    this.path,
  });

  final String name;
  final String content;
  final String? path;

  MarkdownDocument copyWith({String? name, String? content, String? path}) {
    return MarkdownDocument(
      name: name ?? this.name,
      content: content ?? this.content,
      path: path ?? this.path,
    );
  }
}
