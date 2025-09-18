import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart'
    hide IconButton, Card, Divider, DividerThemeData;
import 'package:provider/provider.dart';

import '../../../component/box/custom_sliver_box.dart';
import '../../../component/box/highlight_combo_box.dart';
import '../../../component/box/win_text_box.dart';
import '../../../component/button_with_icon.dart';
import '../../../component/editor/editor.dart';
import '../../../component/text/win_text.dart';
import '../../../constant/macro_trigger_type.dart';
import '../config/config_model.dart';
import 'macro_model.dart';

class MacroEditPage extends StatelessWidget {
  const MacroEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return Consumer<MacroModel>(builder: (context, model, child) {
        return CustomScrollView(
          slivers: [
            CustomSliverBox(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        FluentIcons.back,
                        size: 20,
                      ),
                      onPressed: model.saveThisMicro,
                    ),
                    SizedBox(
                      width: 12,
                    ),
                    WinText(
                      model.isNew ? '新增宏' : '宏 - ${model.editedMacro?.name}',
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            CustomSliverBox(
              child: SizedBox(
                height: 12,
              ),
            ),
            CustomSliverBox(
              child: Card(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          WinText(
                            '基础信息',
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      style: DividerThemeData(
                          thickness: 2, horizontalMargin: EdgeInsets.zero),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    WinText(
                                      '名称',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    SizedBox(
                                      height: 6,
                                    ),
                                    WinTextBox(
                                      controller: model.nameTextController,
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 12,
                              ),
                              Expanded(
                                flex: 4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    WinText(
                                      '触发类型',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    SizedBox(
                                      height: 6,
                                    ),
                                    HighlightComboBox(
                                      value: model
                                          .editedMacro?.triggerType.resourceId,
                                      items: MacroTriggerType.values
                                          .map((e) => e.resourceId)
                                          .toList(),
                                      onChanged: (value) {
                                        model.changeTriggerType(value);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 12,
                              ),
                              Expanded(
                                flex: 4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    WinText(
                                      '触发键',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    SizedBox(
                                      height: 6,
                                    ),
                                    HotkeyBox(
                                      value: model.editedMacro?.triggerKey,
                                      onValueChanged: model.changeTriggerKey,
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    WinText(
                                      '备注',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    SizedBox(
                                      height: 6,
                                    ),
                                    WinTextBox(
                                      controller: model.commentTextController,
                                      maxLines: 3,
                                      minLines: 3,
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    WinText(
                                      '脚本',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    SizedBox(
                                      height: 6,
                                    ),
                                    SizedBox(
                                      height: 300,
                                      child: Editor(
                                        controller: model.scriptController,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          Row(
                            children: [
                              ButtonWithIcon(
                                text: model.recoding ? '停止' : '录制',
                                icon: model.recoding
                                    ? Icons.stop
                                    : Icons.camera_alt,
                                onPressed: model.recoding
                                    ? model.stopRecord
                                    : model.startRecord,
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            CustomSliverBox(
              child: SizedBox(
                height: 12,
              ),
            ),
            CustomSliverBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ButtonWithIcon(
                    text: '保存',
                    icon: Icons.save,
                    onPressed: model.saveThisMicro,
                  ),
                  ButtonWithIcon(
                    text: '删除',
                    icon: Icons.delete,
                    onPressed: model.deleteCurrentMacro,
                  ),
                ],
              ),
            )
          ],
        );
      });
    });
  }
}
