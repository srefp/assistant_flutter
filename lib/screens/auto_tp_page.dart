import 'dart:async';

import 'package:assistant/components/bool_config_row.dart';
import 'package:assistant/components/button_with_icon.dart';
import 'package:assistant/components/highlight_combo_box.dart';
import 'package:assistant/components/icon_card.dart';
import 'package:assistant/components/int_config_row.dart';
import 'package:assistant/components/title_with_sub.dart';
import 'package:assistant/components/win_text_box.dart';
import 'package:assistant/config/auto_tp_config.dart';
import 'package:assistant/notifier/auto_tp_model.dart';
import 'package:assistant/win32/os_version.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:superuser/superuser.dart';

import '../components/dialog.dart';
import '../components/divider.dart';
import '../components/string_config_row.dart';
import '../components/win_text.dart';
import '../theme.dart';

bool finishedSettingTheme = false;
bool win11 = isWindows11();

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

    if (win11 && !finishedSettingTheme) {
      Timer.periodic(Duration(milliseconds: 10), (timer) {
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
                '内置宏',
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
              subTitle: "启动后才能使用各项功能，QQ群660182560",
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
                  TitleWithSub(
                    title: '运行方式',
                    subTitle: '选择全局生效或者是在锚定窗口内生效',
                    rightWidget: SizedBox(
                      width: 280,
                      child: HighlightComboBox(
                        value: model.validType,
                        items: model.validTypeList,
                        onChanged: (value) {
                          model.selectValidType(value);
                        },
                      ),
                    ),
                  ),
                  TitleWithSub(
                    title: '锚定窗口',
                    subTitle: '锚定窗口后，键鼠操作只在窗口内有效',
                    rightWidget: Row(
                      children: [
                        SizedBox(
                            height: 34,
                            child: ButtonWithIcon(
                              icon: Icons.refresh,
                              text: '刷新',
                              onPressed: () {
                                model.loadTasks();
                              },
                            )),
                        SizedBox(
                          width: 12,
                        ),
                        SizedBox(
                          width: 280,
                          child: HighlightComboBox(
                            value: model.anchorWindow,
                            items: model.anchorWindowList,
                            onChanged: (value) {
                              model.selectAnchorWindow(value);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          CustomSliverBox(
            child: IconCard(
              icon: Icons.cases_rounded,
              title: '内置宏配置',
              subTitle: '内置宏，效率较高，操作逻辑固定。',
              content: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 400,
                          height: 34,
                          child: WinTextBox(
                            controller: model.helpSearchController,
                            placeholder: '搜索内置宏',
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
              icon: Icons.rocket_launch_rounded,
              title: '自动传送',
              subTitle: '依据路线自动传送',
              content: Column(
                children: [
                  BoolConfigRow(
                    item: BoolConfigItem(
                      title: '自动传送',
                      subTitle: '是否开启自动传送',
                      valueKey: AutoTpConfig.keyAutoTpEnabled,
                      valueCallback: AutoTpConfig.to.isAutoTpEnabled,
                    ),
                  ),
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
                        width: 280,
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
                        width: 280,
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
                  BoolConfigRow(
                    item: BoolConfigItem(
                      title: '连锄模式',
                      subTitle: '连续锄地模式，如果传送到路线最后一个点位，下一次会传送到第二个点位。',
                      valueKey: AutoTpConfig.keyContinuousMode,
                      valueCallback: AutoTpConfig.to.isContinuousMode,
                    ),
                  ),
                ],
              ),
            ),
          ),
          CustomSliverBox(
            child: IconCard(
              icon: Icons.gamepad_outlined,
              title: '游戏键位',
              subTitle: '根据游戏键位修改耕地机键位，键位名称为英文全小写，例如: m ` capslock tab shift',
              content: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 400,
                          height: 34,
                          child: WinTextBox(
                            controller: model.gameKeySearchController,
                            placeholder: '搜索键位',
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
                      return GameKeyConfigRow(
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
                          child: WinTextBox(
                            controller: model.delaySearchController,
                            placeholder: '搜索延迟',
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
                          child: WinTextBox(
                            controller: model.recordDelaySearchController,
                            placeholder: '搜索延迟',
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
                          child: WinTextBox(
                            controller: model.coordsSearchController,
                            placeholder: '搜索标点',
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
          CustomSliverBox(
            child: IconCard(
              icon: Icons.remove_red_eye,
              title: '匹配区域',
              subTitle: '游戏中标志图像截图与匹配',
              content: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 400,
                          height: 34,
                          child: WinTextBox(
                            controller: model.matchSearchController,
                            placeholder: '搜索匹配区域',
                            onChanged: (value) =>
                                model.searchDisplayedMatchConfigItems(value),
                          ),
                        )
                      ],
                    ),
                  ),
                  divider,
                  ListView.separated(
                    separatorBuilder: (context, index) => divider,
                    itemCount: model.displayedMatchConfigItems.length,
                    itemBuilder: (context, index) {
                      final item = model.displayedMatchConfigItems[index];
                      return StringConfigRow(
                        item: item,
                        lightText: model.delayLightText,
                        rightWidget: SizedBox(
                          height: 34,
                          child: ButtonWithIcon(
                            icon: Icons.remove_red_eye,
                            text: '截图',
                            onPressed: () {
                              model.matchScreenshot(item);
                            },
                          ),
                        ),
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
