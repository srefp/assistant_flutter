import 'package:assistant/config/config_storage.dart';

class HotkeyConfig with ConfigStorage {
  static final HotkeyConfig to = HotkeyConfig();

  static final String keyHalfTp = 'halfTp';
  static final String keyEatFood = 'eatFood';
  static final String keyTpNext = 'tpNext';
  static final String keyTpPrev = 'tpPrev';
  static final String keyQmTpNext = 'qmTpNext';

  String getHalfTp() => box.read(keyHalfTp) ?? 'xbutton2';

  String getEatFood() => box.read(keyEatFood) ?? 'tab';

  String getTpNext() => box.read(keyTpNext) ?? 'right';

  String getTpPrev() => box.read(keyTpPrev) ?? 'left';
}
