import 'package:path/path.dart';

import 'config_storage.dart';

class AppConfig with ConfigStorage {
  static AppConfig to = AppConfig();
  static const keyDirPath = 'dirPath';
  static const keyCurrentApp = 'currentApp';
  static const keyFirstInstall = 'firstInstall';

  String getDirPath() =>
      box.read(keyDirPath) ?? join('C:', 'Program Files', 'Assistant');

  String getExePath() => join(getDirPath(), 'assistant.exe');

  /// 是否是第一次安装
  bool get firstInstall => box.read(keyFirstInstall) ?? true;
}
