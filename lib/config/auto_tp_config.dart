import 'package:assistant/util/route_util.dart';

import 'config_storage.dart';

class AutoTpConfig with ConfigStorage {
  static AutoTpConfig to = AutoTpConfig();
  static const keyAutoTpEnabled = "autoTpEnabled";
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
  static const keyMultiSelectFlowerDelay = "multiSelectFlowerDelay";
  static const keyMultiSelectFlowerAfterDelay = "multiSelectFlowerAfterDelay";
  static const keyFirstOpenBagDelay = "firstOpenBagDelay";
  static const keyOpenBagDelay = "openBagDelay";
  static const keyDragMoveStepDelay = "dragMoveStepDelay";
  static const keyDragReleaseMouseDelay = "dragReleaseMouseDelay";
  static const keyBookDragPixelNum = "bookDragPixelNum";
  static const keyDragPixelNum = "dragPixelNum";
  static const keyCurrentRoute = "currentRoute";
  static const keyContinuousMode = "continuousMode";
  static const keyRouteIndex = "routeIndex";
  static const keyQuickPickEnabled = "quickPickEnabled";
  static const keyMapRecordDelay = "mapRecordDelay";
  static const keyClickRecordDelay = "clickRecordDelay";
  static const keyDragRecordDelay = "dragRecordDelay";
  static const keyShortMoveRecord = "shortMoveRecord";

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

  int getMultiSelectFlowerDelay() => box.read(keyMultiSelectFlowerDelay) ?? 750;

  int getMultiSelectFlowerAfterDelay() =>
      box.read(keyMultiSelectFlowerAfterDelay) ?? 160;

  bool getAutoTpEnabled() => box.read(keyAutoTpEnabled) ?? true;

  int getFirstOpenBagDelay() => box.read(keyFirstOpenBagDelay) ?? 700;

  int getOpenBagDelay() => box.read(keyOpenBagDelay) ?? 500;

  int getDragMoveStepDelay() => box.read(keyDragMoveStepDelay) ?? 60;

  int getDragReleaseMouseDelay() => box.read(keyDragReleaseMouseDelay) ?? 60;

  int getBookDragPixelNum() => box.read(keyBookDragPixelNum) ?? 5;

  int getDragPixelNum() => box.read(keyDragPixelNum) ?? 20;

  String getCrusadePos() => box.read(keyCrusadePos) ?? "9884, 33238";

  String getConfirmPos() => box.read(keyConfirmPos) ?? "55753, 60951";

  List<int> getConfirmPosIntList() =>
      RouteUtil.stringToIntList(box.read(keyConfirmPos)) ?? [55753, 60951];

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

  String? getCurrentRoute() => box.read(keyCurrentRoute);

  bool isContinuousMode() => box.read(keyContinuousMode) ?? false;

  int getRouteIndex() => box.read(keyRouteIndex) ?? 0;

  bool isQuickPickEnabled() => box.read(keyQuickPickEnabled) ?? true;

  int getMapRecordDelay() => box.read(keyMapRecordDelay) ?? 500;

  int getClickRecordDelay() => box.read(keyClickRecordDelay) ?? 60;

  int getDragRecordDelay() => box.read(keyDragRecordDelay) ?? 60;

  int getShortMoveRecord() => box.read(keyShortMoveRecord)?? 20;
}
