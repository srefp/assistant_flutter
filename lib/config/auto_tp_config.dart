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
}
