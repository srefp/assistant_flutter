import 'dart:async';
import 'dart:io';

import 'package:assistant/component/model/config_item.dart';
import 'package:assistant/helper/android/overlay.dart';
import 'package:assistant/helper/isolate/win32_event_listen.dart';
import 'package:assistant/helper/win32/mouse_listen.dart';
import 'package:assistant/main.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:superuser/superuser.dart';
import 'package:window_manager/window_manager.dart';

import '../../../component/box/custom_sliver_box.dart';
import '../../../component/box/highlight_combo_box.dart';
import '../../../component/box/search_box.dart';
import '../../../component/button_with_icon.dart';
import '../../../component/card/icon_card.dart';
import '../../../component/config_row/bool_config_row.dart';
import '../../../component/config_row/double_config_row.dart';
import '../../../component/config_row/hotkey_config_row.dart';
import '../../../component/config_row/int_config_row.dart';
import '../../../component/config_row/process_key_config_row.dart';
import '../../../component/config_row/string_config_row.dart';
import '../../../component/dialog.dart';
import '../../../component/divider.dart';
import '../../../component/text/win_text.dart';
import '../../../component/theme.dart';
import '../../../component/title_with_sub.dart';
import '../../../helper/screen/screen_manager.dart';
import '../../../helper/win32/os_version.dart';
import '../../config/app_config.dart';
import '../../config/auto_tp_config.dart';
import '../../config/hotkey_config.dart';
import 'auto_tp_model.dart';

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
      if (Platform.isWindows) {
        if (!Superuser.isSuperuser || !Superuser.isActivated) {
          dialog(
              title: '未以管理员方式启动！',
              content:
                  '未以管理员方式启动，无法使用窗口检测功能。请通过右下角托盘图标退出程序后，将软件设置为管理员方式启动。具体教程参考gitee下载页面。',
              height: 100);
        }
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
              subTitleSelectable: true,
              rightWidget: SizedBox(
                height: 34,
                child: ButtonWithIcon(
                  icon: model.isRunning ? Icons.stop : Icons.play_arrow,
                  text: model.isRunning ? '停止' : '运行',
                  onPressed: () {
                    if (Platform.isAndroid) {
                      showOverlay(context);
                    } else {
                      model.startOrStop();
                    }
                  },
                ),
              ),
              content: ListView(
                shrinkWrap: true,
                children: [
                  Platform.isWindows
                      ? TitleWithSub(
                          title: '重启',
                          subTitle: '如果程序内存异常增长，可以重启应用解决',
                          rightWidget: SizedBox(
                            height: 34,
                            child: ButtonWithIcon(
                              onPressed: () {
                                restartApp();
                              },
                              text: '重启',
                              icon: Icons.restart_alt,
                            ),
                          ),
                        )
                      : SizedBox(),
                  BoolConfigRow(
                    item: BoolConfigItem(
                      title: '响应模拟键鼠操作',
                      subTitle: '开启响应模拟键鼠操作后，会对模拟的键鼠操作进行响应。一般用于远程解决问题。',
                      valueKey: AutoTpConfig.keyAllowMockKey,
                      valueCallback: AutoTpConfig.to.isAllowMockKey,
                    ),
                  ),
                  BoolConfigRow(
                    item: BoolConfigItem(
                      title: '后台键鼠操作',
                      subTitle: '开启后，后台发送键鼠事件（部分操作可用，建设中...）',
                      valueKey: AppConfig.keyBackgroundKeyMouse,
                      valueCallback: AppConfig.to.isBackgroundKeyMouse,
                    ),
                  ),
                  BoolConfigRow(
                    item: BoolConfigItem(
                      title: '启动时自动切换窗口',
                      subTitle: '点了启动就自动切到监听的窗口',
                      valueKey: AppConfig.keyToWindowAfterStarted,
                      valueCallback: AppConfig.to.getToWindowAfterStarted,
                    ),
                  ),
                  Platform.isWindows
                      ? TitleWithSub(
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
                        )
                      : SizedBox(),
                  if (Platform.isWindows && model.validType == targetWindow)
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
                  if (Platform.isWindows && model.validType == windowHandle)
                    TitleWithSub(
                      title: '窗口句柄',
                      subTitle: '点击获取按钮后单击你想要的窗口即可，句柄是动态的，关闭后需要重新获取。',
                      rightWidget: Row(
                        children: [
                          SizedBox(
                              height: 34,
                              child: ButtonWithIcon(
                                icon: Icons.window,
                                text: '获取',
                                onPressed: () async {
                                  await windowManager.minimize();
                                  startKeyMouseListen();
                                  gettingWindowHandle = true;
                                },
                              )),
                          SizedBox(
                            width: 12,
                          ),
                          SizedBox(
                            width: 280,
                            child: NumberBox(
                              value:
                                  ScreenManager.instance.foregroundWindowHandle,
                              onChanged: (value) {
                                if (value != null) {
                                  ScreenManager
                                      .instance.foregroundWindowHandle = value;
                                }
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
              subTitle:
                  '内置宏，效率较高，操作逻辑固定。单击键位按钮可以监听键鼠进行配置，再次单击不再监听。长按后可以输入键位，回车完成。',
              rightWidget: SizedBox(
                child: ToggleSwitch(
                  checked: AutoTpConfig.to.isInnerMacroEnabled(),
                  onChanged: (value) {
                    setState(() {
                      AutoTpConfig.to
                          .save(AutoTpConfig.keyInnerMacroEnabled, value);
                      final innerMacroEnabled =
                          AutoTpConfig.to.isInnerMacroEnabled();
                      if (!innerMacroEnabled) {
                        AutoTpConfig.to
                            .save(HotkeyConfig.keyShowCoordsEnabled, false);
                        AutoTpConfig.to
                            .save(HotkeyConfig.keyHalfTpEnabled, false);
                        AutoTpConfig.to
                            .save(HotkeyConfig.keyToPrevEnabled, false);
                        AutoTpConfig.to
                            .save(HotkeyConfig.keyToNextEnabled, false);
                        AutoTpConfig.to
                            .save(HotkeyConfig.keyQmAutoTpEnabled, false);
                        AutoTpConfig.to
                            .save(AutoTpConfig.keyQuickPickEnabled, false);
                        AutoTpConfig.to.save(
                            AutoTpConfig.keyToggleQuickPickEnabled, false);
                        AutoTpConfig.to
                            .save(AutoTpConfig.keyAutoTpEnabled, false);
                        AutoTpConfig.to
                            .save(AutoTpConfig.keyDashEnabled, false);
                        AutoTpConfig.to
                            .save(AutoTpConfig.keyEatFoodEnabled, false);
                        AutoTpConfig.to
                            .save(AutoTpConfig.keyFoodRecordEnabled, false);
                        AutoTpConfig.to.save(AutoTpConfig.keyQmDash, false);
                        AutoTpConfig.to
                            .save(AutoTpConfig.keyContinuousMode, false);
                      } else {
                        AutoTpConfig.to
                            .save(HotkeyConfig.keyShowCoordsEnabled, true);
                        AutoTpConfig.to
                            .save(HotkeyConfig.keyHalfTpEnabled, true);
                        AutoTpConfig.to
                            .save(HotkeyConfig.keyToPrevEnabled, true);
                        AutoTpConfig.to
                            .save(HotkeyConfig.keyToNextEnabled, true);
                        AutoTpConfig.to
                            .save(HotkeyConfig.keyQmAutoTpEnabled, true);
                        AutoTpConfig.to
                            .save(AutoTpConfig.keyQuickPickEnabled, true);
                        AutoTpConfig.to
                            .save(AutoTpConfig.keyToggleQuickPickEnabled, true);
                        AutoTpConfig.to
                            .save(AutoTpConfig.keyAutoTpEnabled, true);
                        AutoTpConfig.to.save(AutoTpConfig.keyDashEnabled, true);
                        AutoTpConfig.to
                            .save(AutoTpConfig.keyEatFoodEnabled, true);
                        AutoTpConfig.to
                            .save(AutoTpConfig.keyFoodRecordEnabled, true);
                        AutoTpConfig.to.save(AutoTpConfig.keyQmDash, true);
                        AutoTpConfig.to
                            .save(AutoTpConfig.keyContinuousMode, true);
                      }
                    });
                  },
                ),
              ),
              content: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        SearchBox(
                          searchController: model.helpSearchController,
                          placeholder: '搜索内置宏',
                          onChanged: (value) =>
                              model.searchDisplayedHelpConfigItems(value),
                        ),
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
                      } else if (item is HotkeyConfigItem) {
                        return HotkeyConfigRow(
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
              icon: Icons.gamepad_outlined,
              title: '进程键位',
              subTitle:
                  '根据进程键位修改耕地机键位，键位名称为英文全小写，例如: m ` capslock tab shiftleft',
              content: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        SearchBox(
                          searchController: model.processKeySearchController,
                          onChanged: (value) =>
                              model.searchProcessKeyConfigItems(value),
                          placeholder: '搜索键位',
                        ),
                      ],
                    ),
                  ),
                  divider,
                  ListView.separated(
                    separatorBuilder: (context, index) => divider,
                    itemCount: model.displayedProcessKeyConfigItems.length,
                    itemBuilder: (context, index) {
                      final item = model.displayedProcessKeyConfigItems[index];
                      return ProcessKeyConfigRow(
                        item: item,
                        lightText: model.processKeyLightText,
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
              icon: Icons.code,
              title: '脚本设置',
              subTitle: '设置脚本运行相关配置',
              content: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        SearchBox(
                          searchController: model.scriptSearchController,
                          onChanged: (value) =>
                              model.searchDisplayedScriptConfigItems(value),
                          placeholder: '搜索配置',
                        ),
                      ],
                    ),
                  ),
                  divider,
                  ListView.separated(
                    separatorBuilder: (context, index) => divider,
                    itemCount: model.displayedScriptConfigItems.length,
                    itemBuilder: (context, index) {
                      final item = model.displayedScriptConfigItems[index];
                      return renderItem(item, model.scriptLightText);
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
                        SearchBox(
                          searchController: model.delaySearchController,
                          onChanged: (value) =>
                              model.searchDisplayedDelayConfigItems(value),
                          placeholder: '搜索延迟',
                        ),
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
              icon: Icons.emergency_recording,
              title: '录制参数',
              subTitle: '录制路线时，默认的操作延迟 以及 其他操作参数',
              content: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        SearchBox(
                          searchController: model.recordDelaySearchController,
                          onChanged: (value) => model
                              .searchDisplayedRecordDelayConfigItems(value),
                          placeholder: '搜索延迟',
                        ),
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
              subTitle: '自动识别您的窗口/屏幕分辨率，当前窗口/屏幕：${model.getScreen()}',
              content: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        SearchBox(
                          searchController: model.coordsSearchController,
                          onChanged: (value) =>
                              model.searchDisplayedCoordsConfigItems(value),
                          placeholder: '搜索标点',
                        ),
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
              title: '识图参数',
              subTitle: '识图功能相关参数',
              content: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        SearchBox(
                          searchController: model.matchSearchController,
                          onChanged: (value) =>
                              model.searchDisplayedMatchConfigItems(value),
                          placeholder: '搜索匹配区域',
                        ),
                      ],
                    ),
                  ),
                  divider,
                  ListView.separated(
                    separatorBuilder: (context, index) => divider,
                    itemCount: model.displayedMatchConfigItems.length,
                    itemBuilder: (context, index) {
                      final item = model.displayedMatchConfigItems[index];

                      if (item is DoubleConfigItem) {
                        return DoubleConfigRow(
                          item: item,
                          lightText: model.matchLightText,
                        );
                      } else if (item is StringConfigItem) {
                        return StringConfigRow(
                          item: item,
                          lightText: model.delayLightText,
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
        ],
      );
    });
  }
}
