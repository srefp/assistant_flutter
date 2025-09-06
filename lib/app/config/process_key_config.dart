import 'config_storage.dart';

class ProcessKeyConfig with ConfigStorage {
  static final ProcessKeyConfig to = ProcessKeyConfig();

  static final String keyOpenMapKey = 'openMapKey';
  static final String keyOpenBookKey = 'openBookKey';
  static final String keyOnlineKey = 'onlineKey';
  static final String keyDashKey = 'dashKey';
  static final String keyForwardKey = 'forwardKey';
  static final String keyBagKey = 'bagKey';
  static final String keyPickKey = 'pickKey';
  static final String keyQKey = 'qKey';

  String getOpenMapKey() => box.read(keyOpenMapKey) ?? 'm';

  String getOpenBookKey() => box.read(keyOpenBookKey) ?? 'f1';

  String getOnlineKey() => box.read(keyOnlineKey) ?? 'f2';

  String getDashKey() => box.read(keyDashKey) ?? 'shift';

  String getForwardKey() => box.read(keyForwardKey) ?? 'w';

  String getBagKey() => box.read(keyBagKey) ?? 'b';

  String getPickKey() => box.read(keyPickKey) ?? 'f';

  String getQKey() => box.read(keyQKey) ?? 'q';
}
