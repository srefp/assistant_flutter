import 'package:assistant/components/win_text.dart';
import 'package:assistant/notifier/script_editor_model.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/button_with_icon.dart';
import '../components/editor.dart';

class ScriptEditor extends StatefulWidget {
  const ScriptEditor({super.key});

  @override
  State<ScriptEditor> createState() => _ScriptEditorState();
}

class _ScriptEditorState extends State<ScriptEditor> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ScriptEditorModel>(builder: (context, model, child) {
      return Flex(
        direction: Axis.vertical,
        children: [
          SizedBox(
            height: 34,
            child: Row(
              children: [
                Container(
                  constraints: BoxConstraints(
                    minWidth: 100,
                  ),
                  height: 34,
                  child: ComboBox<String>(
                    value: model.selectedDir,
                    items: model.directories
                        .map(
                          (e) => ComboBoxItem<String>(
                            value: e,
                            child: WinText(e),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      model.selectDir(value);
                    },
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Container(
                  constraints: BoxConstraints(
                    minWidth: 100,
                  ),
                  height: 34,
                  child: ComboBox<String>(
                    value: model.selectedFile,
                    items: model.files
                        .map(
                          (e) => ComboBoxItem<String>(
                            value: e,
                            child: WinText(e),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      model.selectFile(value);
                    },
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                SizedBox(
                  height: 34,
                  child: ButtonWithIcon(
                    icon: Icons.save,
                    text: '保存',
                    onPressed: () {},
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                SizedBox(
                  height: 34,
                  child: ButtonWithIcon(
                    icon: Icons.add,
                    text: '添加',
                    onPressed: () {},
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                SizedBox(
                  height: 34,
                  child: ButtonWithIcon(
                    icon: Icons.play_arrow,
                    text: '运行',
                    onPressed: () {
                      model.runJs();
                    },
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                model.isUnsaved
                    ? Icon(Icons.circle)
                    : SizedBox(width: 0, height: 0),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Editor(
              content: model.fileContent ?? '',
              saveFile: model.saveFile,
            ),
          ),
        ],
      );
    });
  }
}
