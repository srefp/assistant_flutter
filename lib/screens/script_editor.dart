import 'package:assistant/components/highlight_combo_box.dart';
import 'package:assistant/constants/script_type.dart';
import 'package:assistant/notifier/script_editor_model.dart';
import 'package:assistant/util/operation_util.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:provider/provider.dart';

import '../components/button_with_icon.dart';
import '../components/editor.dart';
import '../notifier/script_record_model.dart';

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
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        constraints: BoxConstraints(
                          minWidth: 100,
                        ),
                        width: 100,
                        height: 34,
                        child: HighlightComboBox(
                          value: model.selectedScriptType,
                          items: scriptTypes,
                          onChanged: (value) {
                            model.selectScriptType(value);
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
                          value: model.selectedScriptName,
                          items: model.scriptNameList,
                          onChanged: (value) {
                            model.selectScript(value);
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
                            model.showAddScriptModel(context);
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
                            model.isRunning
                                ? model.stopJs()
                                : model.runJs(context);
                          }),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Consumer<ScriptRecordModel>(
                          builder: (context, model, child) {
                        return SizedBox(
                          height: 34,
                          child: ButtonWithIcon(
                            icon: model.isRecording
                                ? Icons.stop
                                : Icons.fiber_manual_record,
                            text: model.isRecording ? '停止' : '录制',
                            onPressed: () {
                              if (model.isRecording) {
                                model.stopRecord();
                              } else {
                                model.startRecord(context);
                              }
                            },
                          ),
                        );
                      }),
                      SizedBox(
                        width: 10,
                      ),
                      model.isUnsaved
                          ? Icon(Icons.circle)
                          : SizedBox(width: 0, height: 0),
                    ],
                  ),
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 34,
                      height: 34,
                      child: IconButton(
                        icon: Icon(FluentIcons.info_solid, size: 16),
                        onPressed: () => model.showScriptInfo(context),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Editor(
              content: model.scriptContent ?? '',
              saveFile: model.saveScript,
            ),
          ),
        ],
      );
    });
  }
}
