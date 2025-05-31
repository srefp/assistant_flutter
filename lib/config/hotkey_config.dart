import 'package:assistant/config/config_storage.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager_platform_interface/src/hotkey.dart';

import '../util/key_mouse_name.dart';

class HotkeyConfig with ConfigStorage {
  static final HotkeyConfig to = HotkeyConfig();

  static const keyHalfTp = 'halfTp';
  static const keyTpNext = 'tpNext';
  static const keyTpPrev = 'tpPrev';
  static const keyQmTpNext = 'qmTpNext';
  static const keyStartStopKey = 'startStopKey';
  static const keyShowCoordsKey = 'showCoordsKey';
  static const keyQuickPickKey = "quickPickKey";
  static const keyEatFoodKey = 'eatFoodKey';
  static const keyTimerDashKey = "timerDashKey";

  String getStartStopKey() => box.read(keyStartStopKey) ?? 'f7';

  String getShowCoordsKey() => box.read(keyShowCoordsKey) ?? 'up';

  String getHalfTp() => box.read(keyHalfTp) ?? 'xbutton2';

  String getEatFoodKey() => box.read(keyEatFoodKey) ?? '`';

  String getTpNext() => box.read(keyTpNext) ?? 'right';

  String getTpPrev() => box.read(keyTpPrev) ?? 'left';

  String getQuickPickKey() => box.read(keyQuickPickKey) ?? "f";

  String getTimerDashKey() => box.read(keyTimerDashKey) ?? 'v';

  HotKey getStartStopKeyItem() {
    return HotKey(
      identifier: keyStartStopKey,
      key: stringToPhysicalKeyMap[getStartStopKey()] ?? PhysicalKeyboardKey.f7,
      scope: HotKeyScope.system,
      modifiers: [],
    );
  }
}
