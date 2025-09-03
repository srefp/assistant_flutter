import 'dart:io';

import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../app/config/file_info_config.dart';
import 'date_utils.dart';

/// 基本文件存储地址
late final String baseDirPath;

/// 日志文件夹地址
late final String logDirPath;

/// 日志文件地址
late final String logFilePath;

/// 文件夹类型
enum DirectoryType {
  fun('娱乐'),
  tutorial('教程'),
  codeProject('项目代码'),
  dirUnknown('未知');

  final String value;

  const DirectoryType(this.value);

  /// 根据后缀确定文件类型
  static DirectoryType fromString(String type) {
    DirectoryType directoryType = DirectoryType.dirUnknown;
    List<DirectoryType> matchList =
        DirectoryType.values.where((e) => e.value == type).toList();
    if (matchList.isNotEmpty) {
      directoryType = matchList.first;
    }
    return directoryType;
  }
}

/// 文件类型
enum FileType {
  markdown,
  txt,
  code,
  doc,
  excel,
  ppt,
  pdf,
  image,
  music,
  video,
  exe,
  unknown;

  /// 后缀名与类型映射表
  static final fileExtensionMap = {
    'c': code,
    'py': code,
    'js': code,
    'ts': code,
    'go': code,
    'kt': code,
    'sh': code,
    'cpp': code,
    'dart': code,
    'java': code,
    'md': markdown,
    'doc': doc,
    'docx': doc,
    'xls': excel,
    'xlsx': excel,
    'ppt': ppt,
    'pptx': ppt,
    'rm': video,
    'mp4': video,
    'avi': video,
    'wmv': video,
    'mpg': video,
    'mov': video,
    'ram': video,
    'swf': video,
    'flv': video,
    'mpeg': video,
    'bmp': image,
    'dib': image,
    'pcp': image,
    'dif': image,
    'wmf': image,
    'gif': image,
    'jpg': image,
    'tif': image,
    'eps': image,
    'psd': image,
    'cdr': image,
    'iff': image,
    'tga': image,
    'pcd': image,
    'mpt': image,
    'png': image,
    'jpeg': image,
    'tiff': image,
    'mp3': music,
    'wma': music,
    'm4a': music,
    'aac': music,
    'ogg': music,
    'mpc': music,
    'flac': music,
    'ape': music,
    'wv': music,
    'tak': music,
    'tta': music,
    'shorten': music,
    'ncm': music,
    'mflac': music,
    'kgm': music,
    'xm': music,
    'optimfrog': music,
  };

  /// 通过类型确认有多少种后缀名
  static List<String> getExtensions(FileType fileType) {
    Map<FileType, List<String>> reverseMap = {};
    fileExtensionMap.forEach((key, value) {
      if (reverseMap.containsKey(value)) {
        reverseMap[value]!.add(key);
      } else {
        reverseMap[value] = [key];
      }
    });
    return reverseMap[fileType] ?? [];
  }

  /// 根据后缀确定文件类型
  static FileType fromString(String fileExtension) {
    FileType? fileType = fileExtensionMap[fileExtension.toLowerCase()];
    if (fileType != null) {
      return fileType;
    }

    fileType = FileType.unknown;
    List<FileType> matchList =
        FileType.values.where((e) => e.name == fileExtension).toList();
    if (matchList.isNotEmpty) {
      fileType = matchList.first;
    }
    return fileType;
  }
}

late String dataPath;

/// `[系统文档路径]/Efficient` 作为程序数据路径
Future<String> getDataPath() async =>
    join((await getDocumentDir()).path, 'Efficient');

/// 获取系统文档目录
Future<Directory> getDocumentDir() async {
  try {
    return getApplicationDocumentsDirectory();
  } catch (err) {
    rethrow;
  }
}

/// 初始化基本路径
Future<void> initFileManagement() async {
  if (Platform.isWindows) {
    baseDirPath = FileInfoConfig.to.getBaseDirPath();
    logDirPath = join((await getDocumentDir()).path, 'Efficient', 'log');
    logFilePath = join(logDirPath, '${getNowLogString()}.log');
  } else {
    Directory directory = await getApplicationDocumentsDirectory();
    baseDirPath = join(directory.path, 'file_management');
    logDirPath = join(directory.path, 'log');
    logFilePath = join(logDirPath, '${getNowLogString()}.log');
  }
}

/// 文件存储路径
Future<String> fileManagementPath(FileType fileType) async {
  Directory directory = await getApplicationDocumentsDirectory();
  Directory imageDirectory = GetPlatform.isAndroid
      ? Directory(join(directory.path, fileType.name))
      : Directory(join(baseDirPath, fileType.name));
  if (!imageDirectory.existsSync()) {
    imageDirectory.createSync(recursive: true);
  }
  return imageDirectory.path;
}
