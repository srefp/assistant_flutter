import 'config_storage.dart';

/// 录制配置
class RecordConfig with ConfigStorage {
  static RecordConfig to = RecordConfig();
  static const keyEnableDefaultDelay = 'enableDefaultDelay';
  static const keyOpenMapDelay = "openMapDelay";
  static const keyClickDelay = "clickDelay";
  static const keyDragDelay = "dragDelay";
  static const keyClickDiff = "clickDiff";

  bool getEnableDefaultDelay() => box.read(keyEnableDefaultDelay) ?? true;

  int getOpenMapDelay() => box.read(keyOpenMapDelay) ?? 560;

  int getClickDelay() => box.read(keyClickDelay) ?? 90;

  int getDragDelay() => box.read(keyDragDelay) ?? 100;

  /// 判断为单击的最大误差
  int getClickDiff() => box.read(keyClickDiff) ?? 500;
}
