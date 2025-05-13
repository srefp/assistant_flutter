import 'package:assistant/config/hotkey_config.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

import '../app/windows_app.dart';

/// 快捷键
class KeyItem {
  final PhysicalKeyboardKey keyCode;
  final List<HotKeyModifier>? modifiers;
  final HotKeyScope scope;
  final VoidCallback? callback;

  KeyItem(
      this.keyCode, {
        this.modifiers = const [],
        this.scope = HotKeyScope.inapp,
        this.callback,
      });
}

final Map<String, PhysicalKeyboardKey> physicalKeyMap = {
  'f1': PhysicalKeyboardKey.f1,
  'f2': PhysicalKeyboardKey.f2,
  'f3': PhysicalKeyboardKey.f3,
  'f4': PhysicalKeyboardKey.f4,
  'f5': PhysicalKeyboardKey.f5,
  'f6': PhysicalKeyboardKey.f6,
  'f7': PhysicalKeyboardKey.f7,
  'f8': PhysicalKeyboardKey.f8,
  'f9': PhysicalKeyboardKey.f9,
  'f10': PhysicalKeyboardKey.f10,
  'f11': PhysicalKeyboardKey.f11,
  'f12': PhysicalKeyboardKey.f12,
  'enter': PhysicalKeyboardKey.enter,
  'esc': PhysicalKeyboardKey.escape,
};

/// 注册快捷键
void initHotKey() async {
  // 先取消所有注册的全局快捷键
  await hotKeyManager.unregisterAll();
  await hotKeyManager.register(HotkeyConfig.to.getStartStopKeyItem(), keyDownHandler: (hotKey) {
    print('开启');
    WindowsApp.autoTpModel.startOrStop();
  });
}
