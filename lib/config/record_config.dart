import 'config_storage.dart';

/// 录制配置
class RecordConfig with ConfigStorage {
  static RecordConfig to = RecordConfig();
  static const keyEnableDefaultDelay = 'enableDefaultDelay';
  static const keyOpenMapDelay = "openMapDelay";
  static const keyClickDelay = "clickDelay";
  static const keyDragDelay = "dragDelay";
  static const keyClickDiff = "clickDiff";
  static const keyOpenMapKey = "openMapKey";
  static const keyConfirmOperationKey = "confirmOperationKey";
  static const keyConfirmPosition = "confirmPosition";
  static const keyNextKey = "nextKey";
  static const keyPrevKey = "prevKey";
  static const keyShowCoordsKey = "showCoordsKey";

  bool getEnableDefaultDelay() => box.read(keyEnableDefaultDelay) ?? true;

  /// 判断为单击的最大误差
  int getClickDiff() => box.read(keyClickDiff) ?? 500;

}
