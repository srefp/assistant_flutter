import 'package:assistant/components/highlight_combo_box.dart';
import 'package:assistant/notifier/script_editor_model.dart';
import 'package:assistant/util/operation_util.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:provider/provider.dart';

import '../components/button_with_icon.dart';
import '../components/editor.dart';

class ScriptEditor extends StatelessWidget {
  const ScriptEditor({super.key});

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
                  width: 100,
                  height: 34,
                  child: HighlightComboBox(
                    value: model.selectedDir,
                    items: model.directories,
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
                  width: 300,
                  height: 34,
                  child: HighlightComboBox(
                    value: model.selectedFile,
                    items: model.files,
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
                    icon: Icons.add,
                    text: '添加',
                    onPressed: () {
                      model.showAddFileModel(context);
                    },
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                SizedBox(
                  height: 34,
                  child: ButtonWithIcon(
                    icon: model.isRunning ? Icons.stop : Icons.play_arrow,
                    text: model.isRunning ? '停止' : '运行',
                    onPressed: throttle(() async {
                      model.isRunning ? model.stopJs() : model.runJs();
                    }),
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
