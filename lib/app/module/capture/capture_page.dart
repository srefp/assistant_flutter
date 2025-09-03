import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' hide IconButton, Card;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../component/box/custom_sliver_box.dart';
import '../../../component/box/win_text_box.dart';
import '../../../component/button_with_icon.dart';
import '../../../component/divider.dart';
import '../../../component/page_title.dart';
import '../../../component/title_with_sub.dart';
import '../../routes.dart';
import '../../windows_app.dart';
import '../pic/pic_record.dart';
import 'capture_model.dart';

class CaptureManagementPage extends StatelessWidget {
  const CaptureManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PicModel>(
      builder: (context, model, child) {
        return CustomScrollView(
          slivers: [
            PageTitle(title: '截图管理'),
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
                              placeholder: '搜索',
                              onChanged: (value) {
                                model.search(value);
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                    divider,
                    ListView.separated(
                      separatorBuilder: (context, index) => divider,
                      itemCount: model.displayedPicList.length,
                      itemBuilder: (context, index) {
                        final item = model.displayedPicList[index];
                        return PicListRow(
                          item: item,
                          lightText: model.lightText,
                          onSelectValue: model.selectPic,
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
                            model.createNewPic();
                            rootNavigatorKey.currentContext!
                                .push(Routes.picEdit);
                          },
                        ),
                        SizedBox(width: 16),
                        ButtonWithIcon(
                          text: '导出',
                          icon: Icons.output,
                          onPressed: () {
                            model.exportPic();
                          },
                        ),
                        SizedBox(width: 16), // 按钮间距
                        // 新增导入按钮
                        ButtonWithIcon(
                          text: '导入',
                          icon: Icons.input,
                          onPressed: () => model.importPic(),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class PicListRow extends StatelessWidget {
  final PicRecord item;
  final String lightText;
  final ValueChanged<PicRecord> onSelectValue;

  const PicListRow(
      {super.key,
      required this.item,
      required this.lightText,
      required this.onSelectValue});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: TitleWithSub(
              title: '${item.picName} 【${item.key}】',
              subTitle: item.comment,
              lightText: lightText,
              rightWidget: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      size: 16,
                    ),
                    onPressed: () {
                      onSelectValue(item);
                      rootNavigatorKey.currentContext!.push(Routes.picEdit);
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
