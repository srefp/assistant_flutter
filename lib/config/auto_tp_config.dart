import 'package:assistant/auto_gui/system_control.dart';
import 'package:assistant/notifier/auto_tp_model.dart';
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
  static const keyBookDragStartPos = "bookDragStartPos";
  static const keyBossXAxis = "bossXAxis";
  static const keyBossYAxis = "bossYAxis";
  static const keyNarrowPos = "narrowPos";
  static const keyEnlargePos = "enlargePos";
  static const keyTrackBossPos = "trackBossPos";
  static const keyCloseBossDrawerPos = "closeBossDrawerPos";
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
  static const keyBookDragPixelNum = "bookDragPixelNum";
  static const keyDragPixelNum = "dragPixelNum";
  static const keyCurrentRoute = "currentRoute";
  static const keyContinuousMode = "continuousMode";
  static const keyRouteIndex = "routeIndex";
  static const keyQuickPickEnabled = "quickPickEnabled";
  static const keyToggleQuickPickEnabled = "toggleQuickPickEnabled";
  static const keyMapRecordDelay = "mapRecordDelay";
  static const keyClickRecordDelay = "clickRecordDelay";
  static const keyBookRecordDelay = "bookRecordDelay";
  static const keyDragRecordDelay = "dragRecordDelay";
  static const keyShortMoveRecord = "shortMoveRecord";
  static const keyDashEnabled = "dashEnabled";
  static const keyFoodRecordEnabled = "foodRecordEnabled";
  static const keyFoodKey = "foodKey";
  static const keyRecordedFoodPos = "recordedFoodPos";
  static const keyDragMoveToStartDelay = "dragMoveToStartDelay";
  static const keyDragMouseDownDelay = "dragMouseDownDelay";
  static const keyDragShortMoveDelay = "dragShortMoveDelay";
  static const keyDragMoveToEndDelay = "dragMoveToEndDelay";
  static const keyDragMouseUpDelay = "dragMouseUpDelay";
  static const keyEatFoodEnabled = "eatFoodEnabled";
  static const keyGlobalQuickPickEnabled = "globalQuickPickEnabled";
  static const keyDashIntervalDelay = "dashIntervalDelay";
  static const keySmartTpEnabled = "smartTpEnabled";
  static const keyPickTotalDelay = "pickTotalDelay";
  static const keyPickDownDelay = "pickDownDelay";
  static const keyPickUpDelay = "pickUpDelay";
  static const keyAnchorWindow = "anchorWindow";
  static const keyValidType = "validType";
  static const keyQmDash = "qmDash";
  static const keyWorldRect = "worldRect";
  static const keyAnchorRect = "anchorRect";
  static const keyInnerMacroEnabled = "innerMacroEnabled";
  static const keyTrayEnabled = "trayEnabled";

  String getValidType() {
    return box.read(keyValidType) ?? curScreen;
  }

  String? getAnchorWindow() {
    return box.read(keyAnchorWindow);
  }

  int getTpcDelay() => box.read(keyTpcDelay) ?? 10;

  int getTpcRetryDelay() => box.read(keyTpcRetryDelay) ?? 30;

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

  bool isAutoTpEnabled() => box.read(keyAutoTpEnabled) ?? true;

  int getFirstOpenBagDelay() => box.read(keyFirstOpenBagDelay) ?? 700;

  int getOpenBagDelay() => box.read(keyOpenBagDelay) ?? 500;

  int getDragMoveToStartDelay() => box.read(keyDragMoveToStartDelay) ?? 20;

  int getDragMouseDownDelay() => box.read(keyDragMouseDownDelay) ?? 30;

  int getDragShortMoveDelay() => box.read(keyDragShortMoveDelay) ?? 20;

  int getDragMoveToEndDelay() => box.read(keyDragMoveToEndDelay) ?? 66;

  int getDragMouseUpDelay() => box.read(keyDragMouseUpDelay) ?? 30;

  String getCrusadePos() => box.read(keyCrusadePos) ?? "9884, 33238";

  List<int> getCrusadePosIntList() =>
      RouteUtil.stringToIntList(getCrusadePos());

  String getBookDragStartPos() =>
      box.read(keyBookDragStartPos) ?? "32706, 17058";

  String getBossXAxis() => box.read(keyBossXAxis) ?? "17242, 23046, 29362";

  String getBossYAxis() => box.read(keyBossYAxis) ?? "20944";

  String getNarrowPos() => box.read(keyNarrowPos) ?? "1570, 38580";

  String getEnlargePos() => box.read(keyEnlargePos) ?? "1570, 26833";

  String getTrackBossPos() => box.read(keyTrackBossPos) ?? "49420, 51238";

  String getCloseBossDrawerPos() =>
      box.read(keyCloseBossDrawerPos) ?? "63981, 2094";

  String getSelectPos() => box.read(keySelectPos) ?? "46944, 44499";

  String getSelectAreaPos() => box.read(keySelectAreaPos) ?? "59338, 60921";

  String getFirstAreaPos() => box.read(keyFirstAreaPos) ?? "49727, 10897";

  String getAreaRowSpacing() => box.read(keyAreaRowSpacing) ?? "6518";

  String getAreaColSpacing() => box.read(keyAreaColSpacing) ?? "9969";

  String? getCurrentRoute() => box.read(keyCurrentRoute);

  bool isContinuousMode() => box.read(keyContinuousMode) ?? true;

  int getRouteIndex() => box.read(keyRouteIndex) ?? 0;

  bool isQuickPickEnabled() => box.read(keyQuickPickEnabled) ?? true;

  bool isToggleQuickPickEnabled() =>
      box.read(keyToggleQuickPickEnabled) ?? true;

  int getMapRecordDelay() => box.read(keyMapRecordDelay) ?? 550;

  int getClickRecordDelay() => box.read(keyClickRecordDelay) ?? 60;

  int getBookRecordDelay() => box.read(keyBookRecordDelay) ?? 720;

  int getDragRecordDelay() => box.read(keyDragRecordDelay) ?? 0;

  int getShortMoveRecord() => box.read(keyShortMoveRecord) ?? 20;

  bool isDashEnabled() => box.read(keyDashEnabled) ?? true;

  bool isFoodRecordEnabled() => box.read(keyFoodRecordEnabled) ?? true;

  bool isEatFoodEnabled() => box.read(keyEatFoodEnabled) ?? true;

  bool isGlobalQuickPickEnabled() =>
      box.read(keyGlobalQuickPickEnabled) ?? false;

  String getFoodKey() => box.read(keyFoodKey) ?? 'b';

  String getRecordedFoodPos() => box.read(keyRecordedFoodPos) ?? '';

  List<int> getRecordedFoodPosList() =>
      RouteUtil.stringToIntList(getRecordedFoodPos());

  void addFoodPos(String foodPos) {
    var text = box.read(keyRecordedFoodPos) ?? '';
    if (text.isEmpty) {
      box.write(keyRecordedFoodPos, foodPos);
    } else {
      box.write(keyRecordedFoodPos, '$text, $foodPos');
    }
  }

  int getDashIntervalDelay() => box.read(keyDashIntervalDelay) ?? 810;

  bool isSmartTpEnabled() => box.read(keySmartTpEnabled) ?? true;

  int getPickTotalDelay() => box.read(keyPickTotalDelay) ?? 20;

  int getPickDownDelay() => box.read(keyPickDownDelay) ?? 5;

  int getPickUpDelay() => box.read(keyPickUpDelay) ?? 5;

  bool isQmDash() => box.read(keyQmDash) ?? true;

  bool isInnerMacroEnabled() => box.read(keyInnerMacroEnabled) ?? false;

  String getWorldString() =>
      box.read(keyWorldRect) ?? "62684, 2215, 63315, 3247";

  ScreenRect getWorldRect() {
    final worldRect = getWorldString();
    final coords = RouteUtil.stringToIntList(worldRect);
    return ScreenRect(coords[0], coords[1], coords[2], coords[3]);
  }

  String getAnchorString() =>
      box.read(keyAnchorRect) ?? "49761, 60253, 50546, 61710";

  ScreenRect getAnchorRect() {
    final anchorRect = getAnchorString();
    final coords = RouteUtil.stringToIntList(anchorRect);
    return ScreenRect(coords[0], coords[1], coords[2], coords[3]);
  }

  bool isTrayEnabled() => box.read(keyTrayEnabled) ?? false;
}
