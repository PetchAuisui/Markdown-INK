# Markdown Layers

A mobile-first Flutter workspace for opening, editing, and previewing Markdown.
The architecture keeps Markdown content separate from future annotation and
image layers.

## Current features

- Open Markdown files from the native file picker.
- Edit plain Markdown with unsaved-change status.
- Render a selectable preview using Material Design 3.
- Save to the current file or choose a new destination with Save as.
- Confirm before replacing unsaved content.
- Light and dark themes that follow the system setting.

## Architecture

The Markdown feature separates its domain model and repository contract from
file-system integration and presentation state. The workspace composes that
feature with a layer bar. Annotation and image layers are represented as
separate layer types so their state and rendering can be added without mixing
them into Markdown content.

## Development

```sh
flutter pub get
flutter analyze
flutter test
flutter run
```

The app targets Android and iOS for mobile use, with macOS and Web targets for
local development and previewing without a connected mobile device.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
