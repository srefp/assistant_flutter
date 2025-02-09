import 'package:assistant/util/asset_loader.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';

import '../theme.dart';
import 'config_storage.dart';

class SettingConfig with ConfigStorage {
  static SettingConfig to = SettingConfig();
  static const keyThemeMode = 'themeMode';
  static const keyAccentColorName = 'accentColorName';
  static const keyTransparentMode = 'transparentMode';

  ThemeMode getThemeMode() {
    final index = box.read(keyThemeMode);
    if (index == null) {
      return ThemeMode.system;
    }
    return getItemFromArr(ThemeMode.values, index) ?? ThemeMode.system;
  }

  WindowEffect getTransparentMode() {
    final index = box.read(keyTransparentMode);
    if (index == null) {
      return WindowEffect.mica;
    }
    return getItemFromArr(WindowEffect.values, index) ?? WindowEffect.mica;
  }

  AccentColor getAccentColor() {
    final index = box.read(keyAccentColorName);
    if (index == null || index == 0) {
      return systemAccentColor;
    }
    return getItemFromArr(Colors.accentColors, index - 1);
  }
}
