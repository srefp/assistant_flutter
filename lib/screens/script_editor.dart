import 'package:flutter/material.dart';

import '../components/code_editor.dart';

class ScriptEditor extends StatelessWidget {
  const ScriptEditor({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CodeEditor(),
    );
  }
}
