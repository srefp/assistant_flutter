import 'package:assistant/components/button_with_icon.dart';
import 'package:assistant/components/page_title.dart';
import 'package:assistant/model/macro.dart';
import 'package:assistant/notifier/macro_model.dart';
import 'package:assistant/routes/routes.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' hide Card, IconButton;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../app/windows_app.dart';
import '../components/divider.dart';
import '../components/title_with_sub.dart';
import '../components/win_text_box.dart';
import '../constants/profile_status.dart';
import 'auto_tp_page.dart';

class MacroPage extends StatelessWidget {
  const MacroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return Consumer<MacroModel>(builder: (context, model, child) {
        return CustomScrollView(
          slivers: [
            PageTitle(title: '宏'),
            CustomSliverBox(
              child: Card(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 400,
                            height: 34,
                            child: WinTextBox(
                              controller: model.searchController,
                              placeholder: '搜索宏',
                              onChanged: (value) =>
                                  model.searchDisplayedDelayConfigItems(value),
                            ),
                          )
                        ],
                      ),
                    ),
                    divider,
                    ListView.separated(
                      separatorBuilder: (context, index) => divider,
                      itemCount: model.displayedMacroList.length,
                      itemBuilder: (context, index) {
                        final item = model.displayedMacroList[index];
                        return MacroListRow(
                          item: item,
                          lightText: model.lightText,
                          onToggle: () {
                            model.toggleMacroStatus(item);
                          },
                          onSelectValue: model.selectMacro,
                        );
                      },
                      shrinkWrap: true,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ButtonWithIcon(
                          text: '新增',
                          icon: Icons.add,
                          onPressed: () {
                            model.createNewMacro();
                            rootNavigatorKey.currentContext!
                                .push(Routes.macroEdit);
                          },
                        ),
                        SizedBox(width: 16),
                        ButtonWithIcon(
                          text: '导出',
                          icon: Icons.output,
                          onPressed: () {
                            model.exportMacro();
                          },
                        ),
                        SizedBox(width: 16), // 按钮间距
                        // 新增导入按钮
                        ButtonWithIcon(
                          text: '导入',
                          icon: Icons.input,
                          onPressed: () => model.importMacro(),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        );
      });
    });
  }
}

class MacroListRow extends StatefulWidget {
  const MacroListRow({
    super.key,
    required this.item,
    required this.lightText,
    required this.onToggle,
    required this.onSelectValue,
  });

  final Macro item;
  final String lightText;
  final VoidCallback onToggle;
  final ValueChanged<Macro> onSelectValue;

  @override
  State<MacroListRow> createState() => _MacroListRowState();
}

class _MacroListRowState extends State<MacroListRow> {
  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: TitleWithSub(
              title:
                  '${item.name}【 ${item.triggerKey} ${item.triggerType.resourceId} 】',
              subTitle: item.comment ?? '',
              lightText: widget.lightText,
              rightWidget: Row(
                children: [
                  ToggleSwitch(
                    checked: item.status == ProfileStatus.active,
                    onChanged: (value) {
                      setState(() {
                        widget.onToggle();
                      });
                    },
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      size: 16,
                    ),
                    onPressed: () {
                      widget.onSelectValue(widget.item);
                      rootNavigatorKey.currentContext!.push(Routes.macroEdit);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
