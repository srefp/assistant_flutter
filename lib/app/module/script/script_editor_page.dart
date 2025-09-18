import 'package:assistant/app/module/script/script_editor_model.dart';
import 'package:assistant/component/button/tip_icon_button.dart';
import 'package:assistant/helper/operation_util.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:provider/provider.dart';

import '../../../component/box/highlight_combo_box.dart';
import '../../../component/button_with_icon.dart';
import '../../../component/editor/editor.dart';
import '../../../constant/script_record_mode.dart';

class ScriptEditor extends StatelessWidget {
  const ScriptEditor({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ScriptEditorModel>(builder: (context, model, child) {
      return Flex(
        direction: Axis.vertical,
        children: [
          Row(
            children: [
              Expanded(
                child: Wrap(
                  children: [
                    Container(
                      constraints: BoxConstraints(
                        minWidth: 100,
                      ),
                      width: 100,
                      height: 34,
                      child: HighlightComboBox(
                        value: model.selectedScriptRecordMode?.resourceId,
                        items: ScriptRecordMode.values
                            .map((e) => e.resourceId)
                            .toList(),
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
                      width: 280,
                      height: 34,
                      child: HighlightComboBox(
                        value: model.selectedScriptName,
                        items: model.scriptNameList,
                        onChanged: (value) {
                          model.selectScript(value);
                        },
                      ),
                    ),
                    model.selectedScriptRecordMode == ScriptRecordMode.autoTp
                        ? SizedBox(
                            width: 10,
                          )
                        : const SizedBox(),
                    model.selectedScriptRecordMode == ScriptRecordMode.autoTp
                        ? Container(
                            constraints: BoxConstraints(
                              minWidth: 100,
                            ),
                            width: 280,
                            height: 34,
                            child: HighlightComboBox(
                              value: model.currentPos,
                              items: model.posList,
                              onChanged: (value) {
                                model.selectPos(value);
                              },
                            ),
                          )
                        : const SizedBox(),
                    SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                      height: 34,
                      width: 76,
                      child: ButtonWithIcon(
                        icon: Icons.add,
                        text: '添加',
                        onPressed: () {
                          model.showAddScriptModel(context);
                        },
                      ),
                    ),
                    model.selectedScriptRecordMode ==
                            ScriptRecordMode.autoScript
                        ? SizedBox(
                            width: 10,
                          )
                        : const SizedBox(),
                    model.selectedScriptRecordMode ==
                            ScriptRecordMode.autoScript
                        ? SizedBox(
                            height: 34,
                            width: 76,
                            child: ButtonWithIcon(
                              icon: model.isRunning
                                  ? Icons.stop
                                  : Icons.play_arrow,
                              text: model.isRunning ? '停止' : '运行',
                              onPressed: throttle(() async {
                                model.isRunning
                                    ? model.stopJs()
                                    : model.runJs(context);
                              }),
                            ),
                          )
                        : const SizedBox(),
                    SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                      height: 34,
                      width: 76,
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
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    model.isUnsaved
                        ? SizedBox(height: 34, child: Icon(Icons.circle))
                        : SizedBox(width: 0, height: 0),
                  ],
                ),
              ),
              TipIconButton(
                tip: '预定义变量',
                icon: FluentIcons.code,
                onPressed: () => model.showVariable(),
              ),
              TipIconButton(
                tip: '脚本信息',
                icon: FluentIcons.info_solid,
                color: model.errorMessage == null ? null : Colors.red,
                onPressed: () => model.showScriptInfo(),
              ),
            ],
          ),
          Expanded(
            flex: 1,
            child: Editor(
              controller: model.controller,
            ),
          ),
        ],
      );
    });
  }
}
