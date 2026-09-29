enum DocumentLayerType { markdown, annotation, image }

class DocumentLayer {
  const DocumentLayer({required this.type, required this.isVisible});

  final DocumentLayerType type;
  final bool isVisible;
}
