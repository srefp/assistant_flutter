import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

import '../../app/config/hotkey_config.dart';
import '../../app/windows_app.dart';
import '../../main.dart';
import '../rate_limiting/rate_limiting.dart';

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

final startOrStopDebounce = LeadingDebounce(duration: Duration.zero);

/// 注册快捷键
void initHotKey() async {
  // 先取消所有注册的全局快捷键
  await hotKeyManager.unregisterAll();
  await hotKeyManager.register(HotkeyConfig.to.getStartStopKeyItem(),
      keyDownHandler: (hotKey) {
    startOrStopDebounce(() => WindowsApp.autoTpModel.startOrStop(tip: false));
  });
  await hotKeyManager.register(HotkeyConfig.to.getRestartKeyItem(),
      keyDownHandler: (hotKey) {
    restartApp();
  });
}
