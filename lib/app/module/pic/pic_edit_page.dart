import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart'
    hide IconButton, Card, Divider, DividerThemeData;
import 'package:provider/provider.dart';

import '../../../component/box/custom_sliver_box.dart';
import '../../../component/box/win_text_box.dart';
import '../../../component/button_with_icon.dart';
import '../../../component/text/win_text.dart';
import '../capture/capture_model.dart';

class PicEditPage extends StatelessWidget {
  const PicEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PicModel>(builder: (context, model, child) {
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
                    onPressed: model.saveThisPic,
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  WinText(
                    model.isNew ? '新增图片' : '图片 - ${model.editedPic?.picName}',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
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
                                    '键（脚本中按照这个识别！）',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(
                                    height: 6,
                                  ),
                                  WinTextBox(
                                    controller: model.keyTextController,
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
                                    minLines: 2,
                                    maxLines: 2,
                                    controller: model.commentTextController,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        model.imageFile != null
                            ? Row(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        WinText(
                                          '图片',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        SizedBox(
                                          height: 6,
                                        ),
                                        Image.memory(
                                          model.imageFile!,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(
                                            FluentIcons.picture,
                                            size: 24,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : SizedBox.shrink(),
                        model.imageFile != null
                            ? SizedBox(
                                height: 12,
                              )
                            : SizedBox.shrink(),
                        Row(
                          children: [
                            ButtonWithIcon(
                              text: '截图',
                              icon: Icons.camera,
                              onPressed: model.capturePic,
                            ),
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
                  onPressed: model.saveThisPic,
                ),
                ButtonWithIcon(
                  text: '删除',
                  icon: Icons.delete,
                  onPressed: model.deleteCurrentPic,
                ),
              ],
            ),
          )
        ],
      );
    });
  }
}
