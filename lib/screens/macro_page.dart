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
import '../components/win_text.dart';
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
            CustomSliverBox(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: WinText(
                  '宏',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
            ),
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
                              controller: model.macroSearchController,
                              placeholder: '搜索宏',
                              onChanged: (value) =>
                                  model.searchMacroConfigItems(value),
                            ),
                          )
                        ],
                      ),
                    ),
                    divider,
                    ListView.separated(
                      separatorBuilder: (context, index) => divider,
                      itemCount: model.macroList.length,
                      itemBuilder: (context, index) {
                        final item = model.macroList[index];
                        return MacroListRow(
                          item: item,
                          lightText: model.searchText,
                          onToggle: () {
                            model.toggleMacroStatus(item);
                          },
                          onSelectValue: model.selectMacro,
                        );
                      },
                      shrinkWrap: true,
                    ),
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
              title: '${item.name} (${item.triggerType.resourceId} ${item.triggerKey})',
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
