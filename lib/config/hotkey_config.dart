import 'package:assistant/config/config_storage.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager_platform_interface/src/hotkey.dart';

import '../key_mouse/mouse_button.dart';
import '../util/key_mouse_name.dart';

class HotkeyConfig with ConfigStorage {
  static final HotkeyConfig to = HotkeyConfig();

  static const keyHalfTp = 'halfTp';
  static const keyTpNext = 'tpNext';
  static const keyTpPrev = 'tpPrev';
  static const keyToggleRecord = 'toggleRecord';
  static const keyToggleRecordEnabled = 'toggleRecordEnabled';
  static const keyQmTpNext = 'qmTpNext';
  static const keyStartStopKey = 'startStopKey';
  static const keyRestartKey = 'restartKey';
  static const keyShowCoordsKey = 'showCoordsKey';
  static const keyQuickPickKey = "quickPickKey";
  static const keyToggleQuickPickKey = "toggleQuickPickKey";
  static const keyEatFoodKey = 'eatFoodKey';
  static const keyTimerDashKey = "timerDashKey";
  static const keyToPrev = "toPrev";
  static const keyToNext = "toNext";
  static const keyShowCoordsEnabled = "showCoordsEnabled";
  static const keyHalfTpEnabled = "halfTpEnabled";
  static const keyToPrevEnabled = "toPrevEnabled";
  static const keyToNextEnabled = "toNextEnabled";
  static const keyQmAutoTpEnabled = "qmAutoTpEnabled";

  bool isShowCoordsEnabled() => box.read(keyShowCoordsEnabled) ?? true;

  bool isHalfTpEnabled() => box.read(keyHalfTpEnabled) ?? true;

  bool isToPrevEnabled() => box.read(keyToPrevEnabled) ?? true;

  bool isToNextEnabled() => box.read(keyToNextEnabled) ?? true;

  bool isQmAutoTpEnabled() => box.read(keyQmAutoTpEnabled) ?? true;

  String getStartStopKey() => box.read(keyStartStopKey) ?? 'f7';

  String getRestartKey() => box.read(keyRestartKey) ?? 'f9';

  String getShowCoordsKey() => box.read(keyShowCoordsKey) ?? 'up';

  String getHalfTp() => box.read(keyHalfTp) ?? xbutton2;

  String getEatFoodKey() => box.read(keyEatFoodKey) ?? '`';

  String getTpNext() => box.read(keyTpNext) ?? 'right';

  String getTpPrev() => box.read(keyTpPrev) ?? 'left';

  String getQuickPickKey() => box.read(keyQuickPickKey) ?? "f";

  String getTimerDashKey() => box.read(keyTimerDashKey) ?? 'v';

  String getToggleQuickPickKey() => box.read(keyToggleQuickPickKey) ?? xbutton1;

  String getQmTpNext() => box.read(keyQmTpNext) ?? 'left';

  String getToPrev() => box.read(keyToPrev) ?? 'subtract';

  String getToNext() => box.read(keyToNext) ?? 'add';

  String getToggleRecordKey() => box.read(keyToggleRecord) ?? 'middle';

  bool isToggleRecordEnabled() => box.read(keyToggleRecordEnabled) ?? true;

  HotKey getStartStopKeyItem() {
    return HotKey(
      identifier: keyStartStopKey,
      key: stringToPhysicalKeyMap[getStartStopKey()] ?? PhysicalKeyboardKey.f7,
      scope: HotKeyScope.system,
      modifiers: [],
    );
  }

  HotKey getRestartKeyItem() {
    return HotKey(
      identifier: keyRestartKey,
      key: stringToPhysicalKeyMap[getRestartKey()] ?? PhysicalKeyboardKey.f9,
      scope: HotKeyScope.system,
      modifiers: [],
    );
  }
}
