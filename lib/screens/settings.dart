// ignore_for_file: constant_identifier_names

import 'package:assistant/app/windows_app.dart';
import 'package:assistant/components/config_row.dart';
import 'package:assistant/config/dev_config.dart';
import 'package:assistant/config/setting_config.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Tooltip, Colors, ButtonStyle;
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:provider/provider.dart';

import '../components/icon_card.dart';
import '../components/win_text.dart';
import '../theme.dart';
import '../widgets/page.dart';
import 'auto_tp_page.dart';

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

    if (showTools) {
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

    if (showLog) {
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
