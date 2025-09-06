// ignore_for_file: constant_identifier_names

import 'dart:io';

import 'package:assistant/app/windows_app.dart';
import 'package:assistant/component/component.dart';
import 'package:assistant/helper/file_utils.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'
    hide Tooltip, Colors, ButtonStyle, IconButton;
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:provider/provider.dart';

import '../../../component/button_with_icon.dart';
import '../../../component/card/icon_card.dart';
import '../../../component/config_row/base_config_row.dart';
import '../../../component/config_row/int_config_row.dart';
import '../../../component/config_row/string_config_row.dart';
import '../../../component/theme.dart';
import '../../../component/widgets/page.dart';
import '../../../helper/windows/tray.dart';
import '../../config/auto_tp_config.dart';
import '../../config/db_config.dart';
import '../../config/env_config.dart';
import '../../config/setting_config.dart';

const List<String> accentColorNames = [
  'System',
  'Yellow',
  'Orange',
  'Red',
  'Magenta',
  'Purple',
  'Blue',
  'Teal',
  'Green',
];

bool get kIsWindowEffectsSupported {
  return !kIsWeb &&
      [
        TargetPlatform.windows,
        TargetPlatform.linux,
        TargetPlatform.macOS,
      ].contains(defaultTargetPlatform);
}

const _LinuxWindowEffects = [
  WindowEffect.disabled,
  WindowEffect.transparent,
];

const _WindowsWindowEffects = [
  WindowEffect.disabled,
  WindowEffect.solid,
  WindowEffect.transparent,
  WindowEffect.aero,
  WindowEffect.acrylic,
  WindowEffect.mica,
  WindowEffect.tabbed,
];

const _MacosWindowEffects = [
  WindowEffect.disabled,
  WindowEffect.titlebar,
  WindowEffect.selection,
  WindowEffect.menu,
  WindowEffect.popover,
  WindowEffect.sidebar,
  WindowEffect.headerView,
  WindowEffect.sheet,
  WindowEffect.windowBackground,
  WindowEffect.hudWindow,
  WindowEffect.fullScreenUI,
  WindowEffect.toolTip,
  WindowEffect.contentBackground,
  WindowEffect.underWindowBackground,
  WindowEffect.underPageBackground,
];

List<WindowEffect> get currentWindowEffects {
  if (kIsWeb) return [];

  if (defaultTargetPlatform == TargetPlatform.windows) {
    return _WindowsWindowEffects;
  } else if (defaultTargetPlatform == TargetPlatform.linux) {
    return _LinuxWindowEffects;
  } else if (defaultTargetPlatform == TargetPlatform.macOS) {
    return _MacosWindowEffects;
  }

  return [];
}

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> with PageMixin {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    final appTheme = context.watch<AppTheme>();

    return CustomScrollView(
      key: _navigatorKey,
      slivers: [
        CustomSliverBox(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: WinText(
              '设置',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        CustomSliverBox(
          child: SizedBox(height: 16),
        ),
        CustomSliverBox(
          child: IconCard(
            icon: Icons.menu,
            title: '菜单',
            subTitle: '配置菜单是否显示',
            content: ListView(
              shrinkWrap: true,
              children: _buildVisibleMenus(),
            ),
          ),
        ),
        CustomSliverBox(
          child: IconCard(
            icon: Icons.color_lens,
            title: '主题模式',
            content: ListView(
              shrinkWrap: true,
              children: List.generate(ThemeMode.values.length, (index) {
                final mode = ThemeMode.values[index];
                return Padding(
                  padding: const EdgeInsetsDirectional.only(bottom: 8.0),
                  child: RadioButton(
                    checked: appTheme.mode == mode,
                    onChanged: (value) async {
                      if (value) {
                        appTheme.mode = mode;
                        SettingConfig.to
                            .save(SettingConfig.keyThemeMode, mode.index);

                        if (kIsWindowEffectsSupported) {
                          final transitionEffect =
                              appTheme.windowEffect == WindowEffect.mica
                                  ? WindowEffect.tabbed
                                  : WindowEffect.mica;

                          final windowEffect = appTheme.windowEffect;
                          appTheme.windowEffect = transitionEffect;
                          await appTheme.setEffect(
                              appTheme.windowEffect, context);

                          await Future.delayed(Duration(milliseconds: 140));

                          appTheme.windowEffect = windowEffect;
                          if (context.mounted) {
                            await appTheme.setEffect(
                                appTheme.windowEffect, context);
                          }
                        }
                      }
                    },
                    content: WinText({
                      'system': '系统',
                      'light': '明亮',
                      'dark': '黑暗'
                    }['$mode'.replaceAll('ThemeMode.', '')]!),
                  ),
                );
              }),
            ),
          ),
        ),
        CustomSliverBox(
          child: IconCard(
            title: '主题',
            icon: Icons.color_lens,
            content: Wrap(children: [
              Tooltip(
                message: accentColorNames[0],
                child: _buildColorBlock(appTheme, systemAccentColor, 0),
              ),
              ...List.generate(Colors.accentColors.length, (index) {
                final color = Colors.accentColors[index];
                return Tooltip(
                  message: accentColorNames[index + 1],
                  child: _buildColorBlock(appTheme, color, index + 1),
                );
              }),
            ]),
          ),
        ),
        if (kIsWindowEffectsSupported)
          CustomSliverBox(
            child: IconCard(
              icon: Icons.window,
              title: '窗口透明方式',
              content: ListView(
                shrinkWrap: true,
                children: [
                  ...List.generate(currentWindowEffects.length, (index) {
                    final mode = currentWindowEffects[index];
                    return Padding(
                      padding: const EdgeInsetsDirectional.only(bottom: 8.0),
                      child: RadioButton(
                        checked: appTheme.windowEffect == mode,
                        onChanged: (value) {
                          if (value) {
                            appTheme.windowEffect = mode;
                            SettingConfig.to.save(
                                SettingConfig.keyTransparentMode, mode.index);

                            appTheme.setEffect(mode, context);
                          }
                        },
                        content: WinText(
                          {
                            'disabled': '禁用',
                            'solid': '固体',
                            'transparent': '透明',
                            'aero': 'aero',
                            'acrylic': 'acrylic',
                            'mica': '米卡',
                            'tabbed': 'tabbed'
                          }[mode.toString().replaceAll('WindowEffect.', '')]!,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        if (Platform.isWindows)
          CustomSliverBox(
            child: IconCard(
              expandEnabled: false,
              icon: Icons.menu,
              title: '托盘',
              subTitle: '配置托盘是否显示',
              rightWidget: ToggleSwitch(
                checked: AutoTpConfig.to.isTrayEnabled(),
                onChanged: (value) => {
                  setState(() {
                    AutoTpConfig.to.save(AutoTpConfig.keyTrayEnabled, value);

                    if (AutoTpConfig.to.isTrayEnabled()) {
                      initSystemTray();
                    } else {
                      systemTray.destroy();
                    }
                  })
                },
              ),
            ),
          ),
        CustomSliverBox(
          child: IconCard(
            icon: Icons.dataset,
            title: '相关网站',
            subTitle: '更新，提issue',
            content: ListView(
              shrinkWrap: true,
              children: [
                TitleWithSub(
                  title: '更新',
                  subTitle: 'github，有时可能无法正常访问',
                  rightWidget: ButtonWithIcon(
                    icon: Icons.download,
                    onPressed: () {
                      openUrl(
                          'https://github.com/srefp/assistant-docs/releases');
                    },
                    text: '访问',
                  ),
                ),
                TitleWithSub(
                  title: '更新',
                  subTitle: 'gitee，需要下载分卷压缩的所有文件',
                  rightWidget: ButtonWithIcon(
                    icon: Icons.download,
                    onPressed: () {
                      openUrl(
                          'https://gitee.com/srefp/assistant-docs/releases');
                    },
                    text: '访问',
                  ),
                ),
                TitleWithSub(
                  title: '提issue',
                  subTitle: '遇到问题可以提issue，最好包括问题产生的原因，描述的越具体越好。',
                  rightWidget: ButtonWithIcon(
                    icon: Icons.bug_report,
                    onPressed: () {
                      openUrl('https://gitee.com/srefp/assistant-docs/issues');
                    },
                    text: '访问',
                  ),
                ),
              ],
            ),
          ),
        ),
        if (Env.showDb)
          CustomSliverBox(
            child: IconCard(
              icon: Icons.dataset,
              title: '数据库链接',
              subTitle: '连接postgresql数据库',
              rightWidget: ButtonWithIcon(
                icon: Icons.link_rounded,
                onPressed: () {
                  WindowsApp.codeGenModel.testConnection();
                },
                text: '测试连接',
              ),
              content: ListView(
                shrinkWrap: true,
                children: [
                  StringConfigRow(
                    item: StringConfigItem(
                      title: 'Host',
                      valueKey: DbConfig.keyHost,
                      valueCallback: DbConfig.to.getHost,
                    ),
                  ),
                  IntConfigRow(
                    item: IntConfigItem(
                      title: 'Port',
                      valueKey: DbConfig.keyPort,
                      valueCallback: DbConfig.to.getPort,
                    ),
                  ),
                  StringConfigRow(
                    item: StringConfigItem(
                      title: 'Database',
                      valueKey: DbConfig.keyDatabase,
                      valueCallback: DbConfig.to.getDatabase,
                    ),
                  ),
                  StringConfigRow(
                    item: StringConfigItem(
                      title: 'Username',
                      valueKey: DbConfig.keyUsername,
                      valueCallback: DbConfig.to.getUsername,
                    ),
                  ),
                  StringConfigRow(
                    item: StringConfigItem(
                      title: 'Password',
                      valueKey: DbConfig.keyPassword,
                      valueCallback: DbConfig.to.getPassword,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  _buildVisibleMenus() {
    final menus = [
      ConfigRow(
        title: '内置宏',
        content: ToggleSwitch(
          checked: SettingConfig.to.getAutoTpMenu(),
          onChanged: (value) => {
            setState(() {
              SettingConfig.to.save(SettingConfig.keyAutoTpMenu, value);
              WindowsApp.appModel.changeMenu();
            })
          },
        ),
      ),
      ConfigRow(
        title: '自定义宏',
        content: ToggleSwitch(
          checked: SettingConfig.to.getMacroMenu(),
          onChanged: (value) => {
            setState(() {
              SettingConfig.to.save(SettingConfig.keyMacroMenu, value);
              WindowsApp.appModel.changeMenu();
            })
          },
        ),
      ),
      ConfigRow(
        title: '脚本',
        content: ToggleSwitch(
          checked: SettingConfig.to.getScriptMenu(),
          onChanged: (value) => {
            setState(() {
              SettingConfig.to.save(SettingConfig.keyScriptMenu, value);
              WindowsApp.appModel.changeMenu();
            })
          },
        ),
      ),
      ConfigRow(
        title: '脚本管理',
        content: ToggleSwitch(
          checked: SettingConfig.to.getScriptManagementMenu(),
          onChanged: (value) => {
            setState(() {
              SettingConfig.to
                  .save(SettingConfig.keyScriptManagementMenu, value);
              WindowsApp.appModel.changeMenu();
            })
          },
        ),
      ),
      ConfigRow(
        title: '测试页面',
        content: ToggleSwitch(
          checked: SettingConfig.to.getTestMenu(),
          onChanged: (value) {
            setState(() {
              SettingConfig.to.save(SettingConfig.keyTestMenu, value);
              WindowsApp.appModel.changeMenu();
            });
          },
        ),
      ),
      ConfigRow(
        title: '记录',
        content: ToggleSwitch(
          checked: SettingConfig.to.getRecordMenu(),
          onChanged: (value) => {
            setState(() {
              SettingConfig.to.save(SettingConfig.keyRecordMenu, value);
              WindowsApp.appModel.changeMenu();
            })
          },
        ),
      ),
      ConfigRow(
        title: '识图管理',
        content: ToggleSwitch(
          checked: SettingConfig.to.getCaptureManagementMenu(),
          onChanged: (value) => {
            setState(() {
              SettingConfig.to
                  .save(SettingConfig.keyCaptureManagementMenu, value);
              WindowsApp.appModel.changeMenu();
            })
          },
        ),
      ),
      ConfigRow(
        title: '效率',
        content: ToggleSwitch(
          checked: SettingConfig.to.getEfficientMenu(),
          onChanged: (value) => {
            setState(() {
              SettingConfig.to.save(SettingConfig.keyEfficientMenu, value);
              WindowsApp.appModel.changeMenu();
            })
          },
        ),
      ),
      ConfigRow(
        title: '文档',
        content: ToggleSwitch(
          checked: SettingConfig.to.getDocMenu(),
          onChanged: (value) => {
            setState(() {
              SettingConfig.to.save(SettingConfig.keyDocMenu, value);
              WindowsApp.appModel.changeMenu();
            })
          },
        ),
      ),
    ];

    if (Env.showTools) {
      menus.add(
        ConfigRow(
          title: '工具',
          content: ToggleSwitch(
            checked: SettingConfig.to.getToolMenu(),
            onChanged: (value) => {
              setState(() {
                SettingConfig.to.save(SettingConfig.keyToolMenu, value);
                WindowsApp.appModel.changeMenu();
              })
            },
          ),
        ),
      );
    }

    if (Env.showLog) {
      menus.add(
        ConfigRow(
          title: '日志查看',
          content: ToggleSwitch(
            checked: SettingConfig.to.getLogShow(),
            onChanged: (value) => {
              setState(() {
                SettingConfig.to.save(SettingConfig.keyLogShow, value);
                WindowsApp.appModel.changeMenu();
              })
            },
          ),
        ),
      );
    }
    return menus;
  }

  Widget _buildColorBlock(AppTheme appTheme, AccentColor color, int index) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Button(
        onPressed: () {
          appTheme.color = color;
          SettingConfig.to.save(SettingConfig.keyAccentColorName, index);
        },
        style: ButtonStyle(
          padding: const WidgetStatePropertyAll(EdgeInsets.zero),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.isPressed) {
              return color.light;
            } else if (states.isHovered) {
              return color.lighter;
            }
            return color;
          }),
        ),
        child: Container(
          height: 40,
          width: 40,
          alignment: AlignmentDirectional.center,
          child: appTheme.color == color
              ? Icon(
                  FluentIcons.check_mark,
                  color: color.basedOnLuminance(),
                  size: 22.0,
                )
              : null,
        ),
      ),
    );
  }
}
