import 'config_storage.dart';

class AutoTpConfig with ConfigStorage {
  static AutoTpConfig to = AutoTpConfig();
  static const continuousMode = true;
  static const openMapKey = 'm';
  static const openBagKey = 'b';
  static const qKey = 'q';
  static const fKey = 'f';
  static const bookKey = 'F1';
  static const playersKey = 'F2';
  static const tpCooldown = 3000;
  static const halfTpCooldown = 20;
  static const halfTpSleep = 90;
  static const halfTpConfirmSleep = 60;
  static const eatFoodCooldown = 20;
  static const runSleep = 50;
  static const qSleep = 10;
  static const routeDir = "精英";
  static const route = "-6";
  static const autoFoodEnabled = true;
  static const autoTpEnabled = true;
  static const tpMode = "优先开图";
  static const currentPositionName = "不在路线中";
  static const globalQm = false;
  static const keyWindowTitles = "windowTitles";
  static const keyCustomWindowTitle = "customWindowTitle";
  static const keyTpcDelay = "tpcDelay";
  static const keyTpcCooldown = "tpcCooldown";
  static const keyTpcBackDelay = "tpcBackDelay";
  static const keyBossDrawerDelay = "bossDrawerDelay";
  static const keyTpCooldown = "tpCooldown";
  static const keyTpcRetryDelay = "tpcRetryDelay";
  static const keyCrusadePos = "crusadePos";
  static const keyConfirmPos = "confirmPos";
  static const keyBookDragStartPos = "bookDragStartPos";
  static const keyBossXAxis = "bossXAxis";
  static const keyBossYAxis = "bossYAxis";
  static const keyNarrowPos = "narrowPos";
  static const keyEnlargePos = "enlargePos";
  static const keyTrackBossPos = "trackBossPos";
  static const keyCloseBossDrawerPos = "closeBossDrawerPos";
  static const keyFoodPos = "foodPos";
  static const keySelectPos = "selectPos";
  static const keySelectAreaPos = "selectAreaPos";
  static const keyFirstAreaPos = "firstAreaPos";
  static const keyAreaRowSpacing = "areaRowSpacing";
  static const keyAreaColSpacing = "areaColSpacing";
  static const keyFoodCooldown = "foodCooldown";
  static const keyQmDashDelay = "qmDashDelay";
  static const keyQmQDelay = "qmQDelay";
  static const keySelectAreaDelay = "selectAreaDelay";
  static const keyClickDelay = "clickDelay";
  static const keyClickFoodDelay = "clickFoodDelay";
  static const keyEatFoodDelay = "eatFoodDelay";
  static const keyOpenMapDelay = "openMapDelay";
  static const keySwitchAreaDelay = "switchAreaDelay";
  static const keyOpenBookDelay = "openBookDelay";
  static const keyBookOpenMapDelay = "bookOpenMapDelay";
  static const keyPickDelay = "pickDelay";
  static const keyCrusadeDelay = "crusadeDelay";
  static const keyLongPressDelay = "longPressDelay";
  static const keyWheelIntervalDelay = "wheelIntervalDelay";
  static const keyWheelCompleteDelay = "wheelCompleteDelay";
  static const keyMultiSelectDelay = "multiSelectDelay";

  List<String> get windowTitles {
    if (customWindowTitle) {
      return [box.read(keyWindowTitles)];
    } else {
      return ["YuanShen", "GenshinImpact", "Genshin Impact Cloud Game"];
    }
  }

  bool get customWindowTitle => box.read(keyCustomWindowTitle) ?? false;

  int getTpcDelay() => box.read(keyTpcDelay) ?? 10;

  int getTpcRetryDelay() => box.read(keyTpcRetryDelay) ?? 80;

  int getTpcBackDelay() => box.read(keyTpcBackDelay) ?? 30;

  int getTpcCooldown() => box.read(keyTpcCooldown) ?? 200;

  int getBossDrawerDelay() => box.read(keyBossDrawerDelay) ?? 400;

  int getTpCooldown() => box.read(keyTpCooldown) ?? 3000;

  int getFoodCooldown() => box.read(keyFoodCooldown) ?? 2000;

  int getQmDashDelay() => box.read(keyQmDashDelay) ?? 50;

  int getQmQDelay() => box.read(keyQmQDelay) ?? 10;

  int getSelectAreaDelay() => box.read(keySelectAreaDelay) ?? 10;

  int getClickDelay() => box.read(keyClickDelay) ?? 16;

  int getClickFoodDelay() => box.read(keyClickFoodDelay) ?? 50;

  int getEatFoodDelay() => box.read(keyEatFoodDelay) ?? 50;

  int getOpenMapDelay() => box.read(keyOpenMapDelay) ?? 520;

  int getSwitchAreaDelay() => box.read(keySwitchAreaDelay) ?? 180;

  int getOpenBookDelay() => box.read(keyOpenBookDelay) ?? 470;

  int getBookOpenMapDelay() => box.read(keyBookOpenMapDelay) ?? 1000;

  int getPickDelay() => box.read(keyPickDelay) ?? 22;

  int getCrusadeDelay() => box.read(keyCrusadeDelay) ?? 200;

  int getLongPressDelay() => box.read(keyLongPressDelay) ?? 60;

  int getWheelIntervalDelay() => box.read(keyWheelIntervalDelay) ?? 0;

  int getWheelCompleteDelay() => box.read(keyWheelCompleteDelay) ?? 100;

  int getMultiSelectDelay() => box.read(keyMultiSelectDelay) ?? 720;

  String getCrusadePos() => box.read(keyCrusadePos) ?? "9884, 33238";

  String getConfirmPos() => box.read(keyConfirmPos) ?? "55753, 60951";

  String getBookDragStartPos() =>
      box.read(keyBookDragStartPos) ?? "32706, 17058";

  String getBossXAxis() => box.read(keyBossXAxis) ?? "17242, 23046, 29362";

  String getBossYAxis() => box.read(keyBossYAxis) ?? "20944";

  String getNarrowPos() => box.read(keyNarrowPos) ?? "1570, 38580";

  String getEnlargePos() => box.read(keyEnlargePos) ?? "1570, 26833";

  String getTrackBossPos() => box.read(keyTrackBossPos) ?? "49420, 51238";

  String getCloseBossDrawerPos() =>
      box.read(keyCloseBossDrawerPos) ?? "63981, 2094";

  String getFoodPos() => box.read(keyFoodPos) ?? "29464, 3096";

  String getSelectPos() => box.read(keySelectPos) ?? "46944, 44499";

  String getSelectAreaPos() => box.read(keySelectAreaPos) ?? "59338, 60921";

  String getFirstAreaPos() => box.read(keyFirstAreaPos) ?? "49727, 10897";

  String getAreaRowSpacing() => box.read(keyAreaRowSpacing) ?? "6518";

  String getAreaColSpacing() => box.read(keyAreaColSpacing) ?? "9969";
}
