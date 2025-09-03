import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' hide IconButton, Card;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../component/box/custom_sliver_box.dart';
import '../../../component/box/win_text_box.dart';
import '../../../component/button_with_icon.dart';
import '../../../component/divider.dart';
import '../../../component/text/win_text.dart';
import '../../../component/title_with_sub.dart';
import '../../../constant/profile_status.dart';
import '../../routes.dart';
import '../../windows_app.dart';
import 'efficient.dart';
import 'efficient_model.dart';

class EfficientPage extends StatelessWidget {
  const EfficientPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return Consumer<EfficientModel>(builder: (context, model, child) {
        return CustomScrollView(
          slivers: [
            CustomSliverBox(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: WinText(
                  '效率',
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
                              controller: model.searchController,
                              placeholder: '搜索效率',
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
                      itemCount: model.displayedEfficientList.length,
                      itemBuilder: (context, index) {
                        final item = model.displayedEfficientList[index];
                        return EfficientListRow(
                          item: item,
                          lightText: model.lightText,
                          onToggle: () {
                            model.toggleEfficientStatus(item);
                          },
                          onSelectValue: model.selectEfficient,
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
                            model.createNewEfficient();
                            rootNavigatorKey.currentContext!
                                .push(Routes.efficientEdit);
                          },
                        ),
                        SizedBox(width: 16),
                        ButtonWithIcon(
                          text: '导出',
                          icon: Icons.output,
                          onPressed: () {
                            model.exportEfficient();
                          },
                        ),
                        SizedBox(width: 16), // 按钮间距
                        // 新增导入按钮
                        ButtonWithIcon(
                          text: '导入',
                          icon: Icons.input,
                          onPressed: () => model.importEfficient(),
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

class EfficientListRow extends StatefulWidget {
  const EfficientListRow({
    super.key,
    required this.item,
    required this.lightText,
    required this.onToggle,
    required this.onSelectValue,
  });

  final Efficient item;
  final String lightText;
  final VoidCallback onToggle;
  final ValueChanged<Efficient> onSelectValue;

  @override
  State<EfficientListRow> createState() => _EfficientListRowState();
}

class _EfficientListRowState extends State<EfficientListRow> {
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
              title: item.name,
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
