import 'config_storage.dart';

class CvConfig with ConfigStorage {
  static CvConfig to = CvConfig();
  static const prefix = 'cv.';
  static const keyOpenMapDelay = '${prefix}openMapDelay';
  static const keyTpCooldown = '${prefix}tpCooldown';
  static const keyMultiPointerDelay = '${prefix}multiPointerDelay';
  static const keyInfoLoadDelay = '${prefix}infoLoadDelay';
  static const keyMouseBackDelay = '${prefix}mouseBackDelay';

  int getOpenMapDelay() => box.read(keyOpenMapDelay) ?? 450;

  int getTpCooldown() => box.read(keyTpCooldown) ?? 2000;

  int getMultiPointerDelay() => box.read(keyMultiPointerDelay) ?? 350;

  int getInfoLoadDelay() => box.read(keyInfoLoadDelay) ?? 20;

  int getMouseBackDelay() => box.read(keyMouseBackDelay) ?? 20;
}
