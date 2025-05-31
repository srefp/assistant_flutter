import 'package:assistant/config/config_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_auto_gui_windows/types/keyboard_keys.dart';
import 'package:hotkey_manager_platform_interface/src/hotkey.dart';

import '../util/key_mouse_name.dart';

class HotkeyConfig with ConfigStorage {
  static final HotkeyConfig to = HotkeyConfig();

  static const keyHalfTp = 'halfTp';
  static const keyEatFood = 'eatFood';
  static const keyTpNext = 'tpNext';
  static const keyTpPrev = 'tpPrev';
  static const keyQmTpNext = 'qmTpNext';
  static const keyStartStopKey = 'startStopKey';
  static const keyShowCoordsKey = 'showCoordsKey';
  static const keyQuickPickKey = "quickPickKey";

  String getStartStopKey() => box.read(keyStartStopKey) ?? 'f7';

  String getShowCoordsKey() => box.read(keyShowCoordsKey) ?? 'up';

  String getHalfTp() => box.read(keyHalfTp) ?? 'xbutton2';

  String getEatFood() => box.read(keyEatFood) ?? 'tab';

  String getTpNext() => box.read(keyTpNext) ?? 'right';

  String getTpPrev() => box.read(keyTpPrev) ?? 'left';

  String getQuickPickKey() => box.read(keyQuickPickKey) ?? "f";

  HotKey getStartStopKeyItem() {
    return HotKey(
      identifier: keyStartStopKey,
      key: stringToPhysicalKeyMap[getStartStopKey()] ?? PhysicalKeyboardKey.f7,
      scope: HotKeyScope.system,
      modifiers: [],
    );
  }
}
