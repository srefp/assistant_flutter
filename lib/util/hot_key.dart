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

/// 取消注册快捷键
Future<void> unregisterHotKey() async {
  await hotKeyManager.unregisterAll();
}

/// 注册快捷键
void initHotKey() async {
  // 先取消所有注册的全局快捷键
  await hotKeyManager.unregisterAll();
  // 再添加快捷键
  final keyItemList = [
    // 全局快捷键
    // 1. 开启
    KeyItem(
      PhysicalKeyboardKey.f7,
      scope: HotKeyScope.system,
      callback: () {
        WindowsApp.autoTpModel.startOrStop();
      },
    ),
  ];
  for (var e in keyItemList) {
    await registerHotKey(e);
  }
}

/// 注册快捷键
Future<void> registerHotKey(final KeyItem item) async {
  // 再添加全局快捷键
  HotKey hotKey = HotKey(
    key: item.keyCode,
    modifiers: item.modifiers,
    scope: item.scope,
  );
  await hotKeyManager.register(
    hotKey,
    keyDownHandler: (hotKey) => item.callback?.call(),
  );
}
