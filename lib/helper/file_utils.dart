import 'dart:io';

import 'package:assistant/helper/extensions/string_extension.dart';
import 'package:assistant/helper/path_manage.dart';
import 'package:path/path.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:uuid/uuid.dart';

import '../app/config/file_info_config.dart';
import 'log/log_util.dart';

/// 拼接 baseDir 得到真实路径
String getFullPath(String relativePath) => join(baseDirPath, relativePath);

/// 得到相对于 baseDir 的路径
String getRelativePath(String absolutePath) =>
    relative(absolutePath, from: baseDirPath);

/// 更改类型文件夹
Future<String?> moveTypeDir(File file, String newType) async {
  String fileName = basename(file.path);
  final uuid = basename(file.parent.path);
  try {
    await _moveByRename(file.parent, newType);
  } catch (e) {
    appLog.error('更改类型文件夹失败！${e.toString()}');
    return null;
  }
  return join(baseDirPath, newType, uuid, fileName);
}

Future<void> _moveByRename(Directory directory, String newType) async {
  if (await directory.exists()) {
    final name = basename(directory.path);
    final baseDir = directory.parent.parent.path;
    Directory newTypeDirectory = Directory(joinPath(baseDir, newType));
    if (!(await newTypeDirectory.exists())) {
      await newTypeDirectory.create(recursive: true);
    }
    await directory.rename(join(newTypeDirectory.path, name));
  }
}

/// 重命名文件或文件夹
Future<String> renameFileOrDir(
    FileSystemEntity sourceEntity, String newName) async {
  final illegalCharSet = {'/', '\\', '*', '?', '"', '<', '>', '|'};
  for (final ch in illegalCharSet) {
    if (newName.contains(ch)) {
      throw FileSystemException('文件名包含非法字符');
    }
  }
  final type = (await sourceEntity.stat()).type;
  final newPath = join(sourceEntity.parent.path, newName);
  if (type == FileSystemEntityType.file) {
    await File(sourceEntity.path).rename(newPath);
  } else if (type == FileSystemEntityType.directory) {
    await Directory(sourceEntity.path).rename(newPath);
  } else if (type == FileSystemEntityType.link) {
    await Link(sourceEntity.path).rename(newPath);
  }
  return newPath;
}

/// 打开网址
Future<void> openUrl(String? url, {bool notify = true}) async {
  if (url == null || url.isBlank) {
    if (notify) {
      // snack('错误', '网址为空！');
    }
    return;
  }
  try {
    await launchUrlString(url);
  } catch (e) {
    if (notify) {
      // snack('错误', '无法识别此网址');
    }
    appLog.error('无法打开网址！${e.toString()}');
  }
}

/// 运行的东西由其它程序控制，不作为子进程出现（即：当此应用关闭的时候，运行的程序不会被关闭）
Future<void> launchExternal(String path) async {
  await launchUrlString(
    path,
    mode: LaunchMode.externalApplication,
  );
}

/// 判断路径是否是相对路径
/// - 如果是相对路径，拼接基础路径，再打开。
/// - 如果是绝对路径，直接打开。
Future<void> openRelativeOrAbsolute(String? path, {bool notify = true}) async {
  if (path == null || path.isBlank) {
    if (notify) {
      // snack('错误', '路径为空！');
    }
    return;
  }
  if (File(path).isAbsolute) {
    _openFileOrDir(path);
  } else {
    _openFileOrDir(getFullPath(path));
  }
}

/// 打开文件夹
Future<void> _openFileOrDir(String? path, {bool notify = true}) async {
  if (path == null || path.isBlank) {
    if (notify) {
      // snack('错误', '路径为空！');
    }
    return;
  }
  try {
    await launchUrlString(path);
  } catch (e, s) {
    if (notify) {
      // snack('错误', '无法识别路径');
    }
    appLog.error('无法打开路径！${e.toString()}', s);
  }
}

/// 移动文件或文件夹
Future<String> moveFileOrDir({
  required FileSystemEntity sourceEntity,
  required String fileExtension,
  required String directoryType,
}) async {
  if ((await sourceEntity.stat()).type == FileSystemEntityType.directory) {
    return await moveDir(Directory(sourceEntity.path), directoryType);
  } else {
    return await moveFile(File(sourceEntity.path), fileExtension);
  }
}

/// 移动文件夹
Future<String> moveDir(Directory sourceDirectory, String type) async {
  DirectoryType directoryType = DirectoryType.fromString(type);
  // 目录为：基本路径 + 文件类型 + uuid + 原文件名
  final uuid = Uuid().v1();
  String targetPath = join(
      baseDirPath, directoryType.name, uuid, basename(sourceDirectory.path));

  // 创建文件夹
  return await _moveAndDeleteDir(sourceDirectory, targetPath);
}

/// 移动并删除文件夹
Future<String> _moveAndDeleteDir(
    Directory sourceDirectory, String targetPath) async {
  // 创建文件夹
  Directory targetDirectory = Directory(targetPath);
  if (!(await targetDirectory.exists())) {
    await targetDirectory.create(recursive: true);
  }

  // 遍历原目录的所有文件，拷贝到目标目录中
  List<Future> futureFunctionList = [];
  await sourceDirectory.list(recursive: true).forEach((e) {
    final fun = () async {
      FileSystemEntityType type = (await e.stat()).type;
      String relativePath = relative(e.path, from: sourceDirectory.path);
      String itemTargetPath = join(targetPath, relativePath);
      if (type == FileSystemEntityType.file) {
        // 拷贝新文件，拷贝完成后，删除原来的文件
        await _copyAndDeleteFile(File(e.path), itemTargetPath);
      } else if (type == FileSystemEntityType.directory) {
        // 创建空目录
        await _createDirectory(itemTargetPath);
      } else if (type == FileSystemEntityType.link) {
        // 拷贝快捷方式，拷贝完成后，删除原来的快捷方式
        await _copyAndDeleteLink(Link(e.path), itemTargetPath);
      }
    };
    futureFunctionList.add(Future(fun));
  });

  // 等待所有文件拷贝完成
  try {
    await Future.wait(futureFunctionList);
    // 只读文件无法直接删除，因此重新判断其中是否含有只读文件且是否全部复制完毕
    int notCopiedFileNum = 0;
    List<Future> futureList = [];
    await sourceDirectory.list(recursive: true).forEach((e) {
      String relativePath = relative(e.path, from: sourceDirectory.path);
      String itemTargetPath = join(targetPath, relativePath);
      final func = () async {
        // 如果有存在两个文件大小不相等
        FileStat sourceStat = await e.stat();
        if (sourceStat.type == FileSystemEntityType.file) {
          File targetFile = File(itemTargetPath);
          FileStat targetStat = await targetFile.stat();
          if (!(await targetFile.exists()) ||
              sourceStat.size != targetStat.size) {
            notCopiedFileNum++;
          }
        }
      };
      futureList.add(Future(func));
    });

    // 等待全部任务执行完成
    await Future.wait(futureList);

    // 如果未复制的文件数为0，递归删除原文件夹
    if (notCopiedFileNum == 0) {
      await sourceDirectory.delete(recursive: true);
    } else {
      // Get.snackbar('警告', '文件夹中的文件未完全复制！');
    }
  } catch (e) {
    appLog.error(e.toString());
    return targetPath;
  }
  return targetPath;
}

/// 移动文件到文件管理路径中，并返回移动后的路径
Future<String> moveFile(File sourceFile, String type) async {
  FileType fileType = FileType.fromString(type);
  // 判断是否是 typora 文件
  if (FileInfoConfig.to.getTypoMode() && fileType == FileType.markdown) {
    return await moveTypora(sourceFile);
  }
  // 目录为：基本路径 + 文件类型 + uuid + 原文件名
  final uuid = Uuid().v1();
  String targetPath =
      join(baseDirPath, fileType.name, uuid, basename(sourceFile.path));
  return await _copyAndDeleteFile(sourceFile, targetPath);
}

Future<String> _copyAndDeleteFile(File sourceFile, String targetPath) async {
  File targetFile = File(targetPath);
  // 目标文件不存在，递归创建
  if (!(await targetFile.exists())) {
    await targetFile.create(recursive: true);
  }
  // 拷贝文件，遇到异常直接返回
  try {
    await sourceFile.copy(targetPath);
  } catch (e, s) {
    appLog.error('拷贝失败！${e.toString()}', s);
    // snack('错误', '拷贝失败！');
    return targetPath;
  }
  // 检查：
  // 1. 拷贝后的文件存在
  // 2. 源文件可写
  // 3. 拷贝后的文件长度和原文件相同
  FileStat sourceStat = await sourceFile.stat();
  if ((await targetFile.exists()) &&
      fileWritable(sourceStat.mode) &&
      sourceStat.size == (await targetFile.stat()).size) {
    try {
      await sourceFile.delete();
    } catch (e) {
      appLog.error(e.toString());
      // snack('错误', '原文件正在被使用，无法被删除');
    }
  }
  return targetPath;
}

Future<void> _createDirectory(String targetPath) async {
  try {
    Directory directory = Directory(targetPath);
    if (!(await directory.exists())) {
      await directory.create(recursive: true);
    }
  } catch (e) {
    appLog.error('目录创建失败！${e.toString()}');
  }
}

Future<void> _copyAndDeleteLink(Link sourceLink, String targetPath) async {
  try {
    Link link = Link(targetPath);
    if (!(await link.exists())) {
      await link.create(await sourceLink.target(), recursive: true);
    }
    if (await link.exists()) {
      await sourceLink.delete();
    }
  } catch (e) {
    appLog.error('快捷方式拷贝失败！${e.toString()}');
  }
}

/// 文件是否可写
bool fileWritable(int mode) {
  int permissions = mode & 0xFFF;
  int writePermission = (permissions >> 7) & 0x1;
  return writePermission == 1;
}

/// 此操作十分危险，删除文件管理库中的文件或文件夹
Future<void> deleteFileOrDir(File file) async {
  Directory directory = Directory(file.parent.path);

  // 如果目录名是有效的uuid，则删除
  if (Uuid.isValidUUID(fromString: basename(directory.path))) {
    await directory.delete(recursive: true);
  }
}

/// 支持 typora 图片相对路径一起移动的
Future<String> moveTypora(File sourceMarkdown) async {
  FileType fileType = FileType.markdown;
  // 目录为：基本路径 + 文件类型 + uuid + 原文件名
  final uuid = Uuid().v1();
  String markdownTargetPath =
      join(baseDirPath, fileType.name, uuid, basename(sourceMarkdown.path));

  // 拷贝并删除原来的 markdown 文件
  await _copyAndDeleteFile(sourceMarkdown, markdownTargetPath);
  Directory sourceDirectory =
      Directory(sourceMarkdown.path.replaceExtension('md', 'assets'));
  if (await sourceDirectory.exists()) {
    String dirTargetPath =
        join(baseDirPath, fileType.name, uuid, basename(sourceDirectory.path));
    _moveAndDeleteDir(sourceDirectory, dirTargetPath);
  }
  return markdownTargetPath;
}

/// 连接文件夹名和文件名，拼接成完整路径
String joinPath(String dirName, String fileName) {
  if (dirName.endsWith('/')) {
    return '$dirName$fileName';
  } else {
    return '$dirName/$fileName';
  }
}

/// 遍历目录并返回该目录中所有文件的绝对路径
Future<List<String>> dirList(String dirPath) async {
  Stream<FileSystemEntity> fileList = Directory(dirPath).list(recursive: true);

  return fileList
      .where((e) => isFile(e))
      .map((e) => e.path.convertFileSeparator)
      .toList();
}

/// 遍历目录并返回该目录中该层文件的绝对路径
Future<List<String>> dirFirstLayerFileList(String dirPath) async {
  Stream<FileSystemEntity> fileList = Directory(dirPath).list();

  return fileList
      .where((e) => isFile(e))
      .map((e) => e.path.convertFileSeparator)
      .toList();
}

/// 遍历目录并返回该目录中该层文件夹的绝对路径
Future<List<String>> dirFirstLayerDirList(String dirPath) async {
  Stream<FileSystemEntity> fileList = Directory(dirPath).list();

  return fileList
      .where((e) => isDir(e))
      .map((e) => e.path.convertFileSeparator)
      .toList();
}

/// 遍历目录并返回该目录中该层文件的文件名
Future<List<String>> dirFirstLayerFileNameList(String dirPath) async {
  List<String> fileList = await dirFirstLayerFileList(dirPath);
  return fileList.map((e) => getNameFromPath(e)).toList();
}

/// 遍历目录并返回该目录中该层文件夹的文件名
Future<List<String>> dirFirstLayerDirNameList(String dirPath) async {
  List<String> dirList = await dirFirstLayerDirList(dirPath);
  return dirList.map((e) => getNameFromPath(e)).toList();
}

String getNameFromPath(String path) {
  int position = path.convertFileSeparator.lastIndexOf('/') + 1;
  return path.substring(position);
}

/// 判断是否是文件夹
bool isDir(FileSystemEntity entity) {
  FileSystemEntityType type = FileSystemEntity.typeSync(entity.path);
  return type == FileSystemEntityType.directory;
}

/// 判断是否是文件
bool isFile(FileSystemEntity entity) {
  FileSystemEntityType type = FileSystemEntity.typeSync(entity.path);
  return type == FileSystemEntityType.file;
}
