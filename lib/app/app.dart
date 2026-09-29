import 'package:flutter/material.dart';

import '../features/workspace/presentation/workspace_screen.dart';
import 'theme/app_theme.dart';

class MarkdownLayersApp extends StatelessWidget {
  const MarkdownLayersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Markdown Layers',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const WorkspaceScreen(),
    );
  }
}
