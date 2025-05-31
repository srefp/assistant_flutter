import 'package:assistant/config/config_storage.dart';

class GameKeyConfig with ConfigStorage {
  static final GameKeyConfig to = GameKeyConfig();

  static final String keyOpenMapKey = 'openMapKey';
  static final String keyOpenBookKey = 'openBookKey';
  static final String keyOnlineKey = 'onlineKey';
  static final String keyDashKey = 'dashKey';
  static final String keyForwardKey = 'forwardKey';
  static final String keyBagKey = 'bagKey';

  String getOpenMapKey() => box.read(keyOpenMapKey) ?? 'm';

  String getOpenBookKey() => box.read(keyOpenBookKey) ?? 'f1';

  String getOnlineKey() => box.read(keyOnlineKey) ?? 'f2';

  String getDashKey() => box.read(keyDashKey) ?? 'shift';

  String getForwardKey() => box.read(keyForwardKey) ?? 'w';

  String getBagKey() => box.read(keyBagKey) ?? 'b';
}
