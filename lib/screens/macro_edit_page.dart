import 'package:assistant/components/button_with_icon.dart';
import 'package:assistant/components/editor.dart';
import 'package:assistant/components/win_text_box.dart';
import 'package:assistant/constants/macro_trigger_type.dart';
import 'package:assistant/notifier/config_model.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart'
    hide IconButton, Card, Divider, DividerThemeData;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../app/windows_app.dart';
import '../components/highlight_combo_box.dart';
import '../components/win_text.dart';
import '../notifier/macro_model.dart';
import '../routes/routes.dart';
import 'auto_tp_page.dart';

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
                      onPressed: () =>
                          rootNavigatorKey.currentContext!.pop(),
                    ),
                    SizedBox(
                      width: 12,
                    ),
                    WinText(
                      '宏 - ${model.editedMacro?.name}',
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
                                        onContentChanged: model.onScriptChanged,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
                children: [
                  ButtonWithIcon(
                    text: '保存',
                    icon: Icons.save,
                    onPressed: model.saveMicro,
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
