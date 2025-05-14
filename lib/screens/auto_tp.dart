import 'dart:async';

import 'package:assistant/components/bool_config_row.dart';
import 'package:assistant/components/button_with_icon.dart';
import 'package:assistant/components/highlight_combo_box.dart';
import 'package:assistant/components/icon_card.dart';
import 'package:assistant/components/int_config_row.dart';
import 'package:assistant/components/title_with_sub.dart';
import 'package:assistant/notifier/auto_tp_model.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:superuser/superuser.dart';

import '../components/dialog.dart';
import '../components/divider.dart';
import '../components/string_config_row.dart';
import '../components/win_text.dart';
import '../theme.dart';

bool finishedSettingTheme = false;

class AutoTpPage extends StatefulWidget {
  const AutoTpPage({super.key});

  @override
  State<AutoTpPage> createState() => _AutoTpPageState();
}

class _AutoTpPageState extends State<AutoTpPage> {
  int tryTimes = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showOutDate();
      if (!Superuser.isSuperuser || !Superuser.isActivated) {
        dialog(
            title: '未以管理员方式启动！',
            content:
                '未以管理员方式启动，无法使用游戏检测功能。请通过右下角托盘图标退出程序后，将软件设置为管理员方式启动。具体教程参考gitee下载页面。',
            height: 100);
      }
    });
  }

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

    return Consumer<AutoTpModel>(builder: (context, model, child) {
      return CustomScrollView(
        slivers: [
          CustomSliverBox(
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: WinText(
                '自动传送',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
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
                        text: '重新加载路线',
                        icon: FluentIcons.refresh,
                        onPressed: () {
                          model.loadRoutes();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          CustomSliverBox(
            child: IconCard(
              icon: Icons.rocket_launch_rounded,
              title: '自动传送',
              subTitle: '依据路线自动传送',
              content: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: TitleWithSub(
                          title: '路线',
                          subTitle: '重新选择路线起始位置置零',
                        ),
                      ),
                      SizedBox(
                        width: 300,
                        child: HighlightComboBox(
                          value: model.currentRoute,
                          items: model.routeNames,
                          onChanged: (value) {
                            model.selectRoute(value);
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: TitleWithSub(
                          title: '当前位置',
                          subTitle: '支持选择你现在所在的位置',
                        ),
                      ),
                      SizedBox(
                        width: 300,
                        child: HighlightComboBox(
                          value: model.currentPos,
                          items: model.posList,
                          onChanged: (value) {
                            model.selectPos(value);
                          },
                        ),
                      ),
                    ],
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
                            controller: model.gameKeySearchController,
                            placeholder: '搜索键位',
                            style: TextStyle(fontFamily: fontFamily),
                            onChanged: (value) =>
                                model.searchGameKeyConfigItems(value),
                          ),
                        )
                      ],
                    ),
                  ),
                  divider,
                  ListView.separated(
                    separatorBuilder: (context, index) => divider,
                    itemCount: model.displayedGameKeyConfigItems.length,
                    itemBuilder: (context, index) {
                      final item = model.displayedGameKeyConfigItems[index];
                      return StringConfigRow(
                        item: item,
                        lightText: model.gameKeyLightText,
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
              icon: Icons.cases_rounded,
              title: '其他辅助',
              subTitle: '其他辅助功能',
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
                            controller: model.helpSearchController,
                            placeholder: '搜索辅助功能',
                            style: TextStyle(fontFamily: fontFamily),
                            onChanged: (value) =>
                                model.searchDisplayedHelpConfigItems(value),
                          ),
                        )
                      ],
                    ),
                  ),
                  divider,
                  ListView.separated(
                    separatorBuilder: (context, index) => divider,
                    itemCount: model.displayedHelpConfigItems.length,
                    itemBuilder: (context, index) {
                      final item = model.displayedHelpConfigItems[index];

                      if (item is BoolConfigItem) {
                        return BoolConfigRow(
                          item: item,
                          lightText: model.helpLightText,
                        );
                      } else if (item is StringConfigItem) {
                        return StringConfigRow(
                          item: item,
                          lightText: model.helpLightText,
                        );
                      }
                      return null;
                    },
                    shrinkWrap: true,
                  ),
                ],
              ),
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
                      return IntConfigRow(
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
              icon: Icons.access_time_outlined,
              title: '录制参数',
              subTitle: '录制路线时，默认的操作延迟 以及 其他操作参数',
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
                            controller: model.recordDelaySearchController,
                            placeholder: '搜索延迟',
                            style: TextStyle(fontFamily: fontFamily),
                            onChanged: (value) => model
                                .searchDisplayedRecordDelayConfigItems(value),
                          ),
                        )
                      ],
                    ),
                  ),
                  divider,
                  ListView.separated(
                    separatorBuilder: (context, index) => divider,
                    itemCount: model.displayedRecordDelayConfigItems.length,
                    itemBuilder: (context, index) {
                      final item = model.displayedRecordDelayConfigItems[index];
                      return IntConfigRow(
                        item: item,
                        lightText: model.recordDelayLightText,
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
              subTitle: '自动识别您的游戏/屏幕分辨率，当前游戏/屏幕：${model.getScreen()}',
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
                      return StringConfigRow(
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
