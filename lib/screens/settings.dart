// ignore_for_file: constant_identifier_names

import 'package:assistant/config/setting_config.dart';
import 'package:flutter/foundation.dart';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:provider/provider.dart';

import '../components/win_text.dart';
import '../theme.dart';
import '../widgets/page.dart';

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
  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    final appTheme = context.watch<AppTheme>();
    const spacer = SizedBox(height: 10.0);
    const biggerSpacer = SizedBox(height: 40.0);

    return ListView(
      padding: EdgeInsets.all(20),
      children: [
        WinText(
          '设置',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        WinText('菜单', style: FluentTheme.of(context).typography.subtitle),
        spacer,
        WinText('主题模式', style: FluentTheme.of(context).typography.subtitle),
        spacer,
        ...List.generate(ThemeMode.values.length, (index) {
          final mode = ThemeMode.values[index];
          return Padding(
            padding: const EdgeInsetsDirectional.only(bottom: 8.0),
            child: RadioButton(
              checked: appTheme.mode == mode,
              onChanged: (value) async {
                if (value) {
                  appTheme.mode = mode;
                  SettingConfig.to.save(SettingConfig.keyThemeMode, mode.index);

                  if (kIsWindowEffectsSupported) {
                    final transitionEffect =
                        appTheme.windowEffect == WindowEffect.mica
                            ? WindowEffect.tabbed
                            : WindowEffect.mica;

                    final windowEffect = appTheme.windowEffect;
                    appTheme.windowEffect = transitionEffect;
                    await appTheme.setEffect(appTheme.windowEffect, context);

                    await Future.delayed(Duration(milliseconds: 140));

                    appTheme.windowEffect = windowEffect;
                    if (context.mounted) {
                      await appTheme.setEffect(appTheme.windowEffect, context);
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
        biggerSpacer,
        WinText('主题', style: FluentTheme.of(context).typography.subtitle),
        spacer,
        Wrap(children: [
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
        if (kIsWindowEffectsSupported) ...[
          biggerSpacer,
          WinText(
            '窗口透明方式',
            style: FluentTheme.of(context).typography.subtitle,
          ),
          spacer,
          ...List.generate(currentWindowEffects.length, (index) {
            final mode = currentWindowEffects[index];
            return Padding(
              padding: const EdgeInsetsDirectional.only(bottom: 8.0),
              child: RadioButton(
                checked: appTheme.windowEffect == mode,
                onChanged: (value) {
                  if (value) {
                    appTheme.windowEffect = mode;
                    SettingConfig.to.save(SettingConfig.keyTransparentMode, mode.index);

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
      ],
    );
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
