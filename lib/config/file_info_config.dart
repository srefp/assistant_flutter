import 'package:path/path.dart';

import 'config_storage.dart';

class FileInfoConfig with ConfigStorage {
  static FileInfoConfig to = FileInfoConfig();
  static const keyBaseDirPath = 'baseDirPath';
  static const keyTypoMode = 'typoMode';
  static const keyBatchMode = 'batchMode';

  String getBaseDirPath() =>
      box.read(keyBaseDirPath) ?? join('D:', 'srefp', 'file_management');

  bool getTypoMode() => box.read(keyTypoMode) ?? true;

  bool getBatchMode() => box.read(keyBatchMode) ?? false;
}
