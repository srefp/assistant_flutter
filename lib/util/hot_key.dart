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

/// 注册快捷键
void initHotKey() async {
  // 先取消所有注册的全局快捷键
  await hotKeyManager.unregisterAll();
  await hotKeyManager.register(HotkeyConfig.to.getStartStopKeyItem(), keyDownHandler: (hotKey) {
    WindowsApp.autoTpModel.startOrStop();
  });
}
