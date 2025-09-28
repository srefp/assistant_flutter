import 'dart:io';

import 'package:assistant/helper/path_manage.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';

import '../../app/config/auto_tp_config.dart';
import '../../component/text/win_text.dart';
import '../date_utils.dart';
import '../file_utils.dart';

/// 日志工具
LogUtil appLog = LogUtil('app_log');

class LogUtil {
  /// 日志文件流
  late final IOSink fileStream;

  /// 日志记录者名称
  final String loggerName;

  LogUtil(this.loggerName) {
    File logFile = File(logFilePath);
    if (!logFile.existsSync()) {
      logFile.createSync(recursive: true);
    }
    fileStream = logFile.openWrite(mode: FileMode.append);
  }

  LogUtil.server(this.loggerName, String logDirPath) {
    _iniOnServerIsolate(logDirPath);
  }

  void _iniOnServerIsolate(String logDirPath) {
    final logFilePath = join(logDirPath, '${getNowLogString()}_server.log');
    File logFile = File(logFilePath);
    if (!logFile.existsSync()) {
      logFile.createSync(recursive: true);
    }
    fileStream = logFile.openWrite(mode: FileMode.append);
  }

  void dispose() {
    fileStream.close();
  }

  String _process(String msg, String level) =>
      '${getNowMilliSecString()}  $level : $msg';

  void _processAndWrite(String msg, String level, [bool toFile = true]) {
    if (!AutoTpConfig.to.isLogEnabled()) {
      return;
    }
    msg = _process(msg, level);
    debugPrint('[$loggerName] $msg');
    if (toFile) {
      fileStream.writeln(msg);
    }
  }

  /// 只在控制台中打印调试信息
  void normalPrint(dynamic msg, [String? varname]) {
    if (varname != null) {
      print(varname);
    }
    print(msg);
  }

  void debug(String msg) {
    _processAndWrite(msg, 'DEBUG');
  }

  void info(String msg) {
    _processAndWrite(msg, 'INFO');
  }

  void warning(String msg) {
    _processAndWrite(msg, 'WARNING');
  }

  void error(String msg, [StackTrace? s]) {
    _processAndWrite(msg, 'ERROR');
    if (s != null) {
      debugPrint('stack trace: ');
      print(s);
    }
  }

  void critical(String msg) {
    _processAndWrite(msg, 'CRITICAL');
  }

  /// 清空日志
  void clearLogs() {
    Directory directory = Directory(logDirPath);
    directory.list().forEach((e) {
      if (e.path != logFilePath) {
        e.delete();
      }
    });
  }
}

/// 查看运行日志
Future<void> openLog(String logFilePath) async {
  if (Platform.isWindows) {
    await openRelativeOrAbsolute(logFilePath);
  } else {
    File logFile = File(logFilePath);
    if (!logFile.existsSync()) {
      logFile.createSync(recursive: true);
    }
    String logInfo = await logFile.readAsString();
    Get.defaultDialog(
      title: '日志信息',
      content: SizedBox(
        width: 200,
        height: 400,
        child: ListView(
          children: [
            WinText(logInfo),
          ],
        ),
      ),
    );
  }
}
