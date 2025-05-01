import 'dart:async';

import 'package:assistant/components/button_with_icon.dart';
import 'package:assistant/components/delay_config_row.dart';
import 'package:assistant/components/icon_card.dart';
import 'package:assistant/components/title_with_sub.dart';
import 'package:assistant/notifier/auto_tp_model.dart';
import 'package:assistant/util/asset_loader.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/coords_config_row.dart';
import '../components/win_text.dart';
import '../theme.dart';
import '../util/file_utils.dart';

bool finishedSettingTheme = false;

class AutoTpPage extends StatefulWidget {
  const AutoTpPage({super.key});

  @override
  State<AutoTpPage> createState() => _AutoTpPageState();
}

class _AutoTpPageState extends State<AutoTpPage> {
  int tryTimes = 0;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.watch<AppTheme>();

    if (!finishedSettingTheme) {
      Timer.periodic(Duration(milliseconds: 5), (timer) {
        if (context.mounted) {
          appTheme.setEffect(appTheme.windowEffect, context);
        }

        if (tryTimes >= 10) {
          timer.cancel();
          finishedSettingTheme = true;
        }

        tryTimes++;
      });
    }

    final divider = Container(
      height: 1,
      color: Color(0xFF666666),
    );

    return Consumer<AutoTpModel>(builder: (context, model, child) {
      return CustomScrollView(
        slivers: [
          CustomSliverBox(
            child: WinText(
              '自动传送',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
          CustomSliverBox(
            child: SizedBox(height: 16),
          ),
          CustomSliverBox(
            child: IconCard(
              icon: Icons.play_arrow_rounded,
              title: '耕地机，启动！',
              subTitle: "启动后才能使用各项功能",
              rightWidget: SizedBox(
                height: 34,
                child: ButtonWithIcon(
                  icon: model.isRunning ? Icons.stop : Icons.play_arrow,
                  text: model.isRunning ? '停止' : '运行',
                  onPressed: () {
                    if (model.isRunning) {
                      model.stop();
                    } else {
                      model.start();
                    }
                  },
                ),
              ),
              content: ListView(
                shrinkWrap: true,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: TitleWithSub(
                            title: '路线文件夹',
                            subTitle:
                                '每次更新后会覆盖你写的路线，请千万记得备份！请按照文档写路线并将文件发送到QQ群660182560'),
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      ButtonWithIcon(
                        text: '打开路线目录',
                        icon: FluentIcons.open_folder_horizontal,
                        onPressed: () {
                          openRelativeOrAbsolute(getAssets('routes'));
                        },
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      ButtonWithIcon(
                        text: '重新加载路线',
                        icon: FluentIcons.refresh,
                        onPressed: () {
                          openRelativeOrAbsolute(getAssets('routes'));
                        },
                      ),
                    ],
                  ),
                  Row(),
                ],
              ),
            ),
          ),
          CustomSliverBox(
            child: IconCard(
              icon: Icons.rocket_launch_rounded,
              title: '自动传送',
              subTitle: '依据路线自动传送',
              content: Flex(
                direction: Axis.horizontal,
                children: [
                  Expanded(
                    flex: 1,
                    child: TitleWithSub(
                      title: '路线',
                      subTitle: '重新选择路线起始位置置零',
                    ),
                  ),
                  ComboboxFormField(
                    items: [],
                    onChanged: (value) {},
                  ),
                ],
              ),
            ),
          ),
          CustomSliverBox(
            child: IconCard(
              icon: Icons.gamepad_outlined,
              title: '游戏键位',
              subTitle: '根据游戏键位修改耕地机键位，键位名称为英文全小写',
              content: Flex(
                direction: Axis.horizontal,
                children: [
                  Expanded(
                    flex: 1,
                    child: TitleWithSub(
                      title: '打开地图',
                      subTitle: '打开地图后自动传送',
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    height: 46,
                    child: TextBox(
                      onChanged: (value) {},
                    ),
                  ),
                ],
              ),
            ),
          ),
          CustomSliverBox(
            child: IconCard(
              icon: Icons.cases_rounded,
              title: '其他辅助',
              subTitle: '其他辅助功能',
            ),
          ),
          CustomSliverBox(
            child: IconCard(
              icon: Icons.fastfood,
              title: '一键吃药',
              subTitle: '自动吃预设的食物',
            ),
          ),
          CustomSliverBox(
            child: IconCard(
              icon: Icons.access_time_outlined,
              title: '延迟设置',
              subTitle: '设置键鼠操作的延迟',
              content: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 400,
                          height: 34,
                          child: TextBox(
                            controller: model.delaySearchController,
                            placeholder: '搜索延迟',
                            style: TextStyle(fontFamily: fontFamily),
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
                    itemCount: model.displayedDelayConfigItems.length,
                    itemBuilder: (context, index) {
                      final item = model.displayedDelayConfigItems[index];
                      return DelayConfigRow(
                        item: item,
                        lightText: model.delayLightText,
                      );
                    },
                    shrinkWrap: true,
                  ),
                ],
              ),
            ),
          ),
          CustomSliverBox(
            child: IconCard(
              icon: Icons.pin_drop,
              title: '关键位置标点',
              subTitle: '默认为16:9屏幕，其他比例屏幕需要自己标注',
              content: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 400,
                          height: 34,
                          child: TextBox(
                            controller: model.coordsSearchController,
                            placeholder: '搜索标点',
                            style: TextStyle(fontFamily: fontFamily),
                            onChanged: (value) =>
                                model.searchDisplayedCoordsConfigItems(value),
                          ),
                        )
                      ],
                    ),
                  ),
                  divider,
                  ListView.separated(
                    separatorBuilder: (context, index) => divider,
                    itemCount: model.displayedCoordsConfigItems.length,
                    itemBuilder: (context, index) {
                      final item = model.displayedCoordsConfigItems[index];
                      return CoordsConfigRow(
                        item: item,
                        lightText: model.coordsLightText,
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
  }
}

class CustomSliverBox extends StatelessWidget {
  final Widget child;

  const CustomSliverBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverToBoxAdapter(
        child: child,
      ),
    );
  }
}
