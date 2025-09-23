import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:assistant/app/windows_app.dart';
import 'package:assistant/helper/db_helper.dart';
import 'package:assistant/helper/path_manage.dart';
import 'package:assistant/helper/toast/message_pump_helper.dart';
import 'package:assistant/helper/windows/window_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:get_storage/get_storage.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:system_theme/system_theme.dart';
import 'package:window_manager/window_manager.dart';
import 'package:windows_single_instance/windows_single_instance.dart';

import 'app/config/config_storage.dart';
import 'app/module/overlay/overlay_window.dart';
import 'helper/isolate/win32_event_listen.dart';
import 'helper/windows/tray.dart';

const String version = '2025.9.23.2';
const String appId = 'assistant';
const int versionCode = 1;
const String appTitle = '耕地机 v$version';
final DateTime outDate = DateTime(2025, 12, 1);
const restart = 'restart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  initOverlayListening();
  if (!kDebugMode) {
    await WindowsSingleInstance.ensureSingleInstance(
      args,
      appId,
      onSecondWindow: (args) {
        if (args.isNotEmpty && restart == args.first) {
          exit(0);
        }
      },
      bringWindowToFront: true,
    );
  }
  await _initApp();

  runApp(const WindowsApp());
}

void initOverlayListening() {
  final ReceivePort uiReceivePort = ReceivePort();
  // 注册UI端口，对应overlay中的_kPortNameHome('UI')
  IsolateNameServer.registerPortWithName(
    uiReceivePort.sendPort,
    'UI', // 必须与overlay中查找的端口名一致
  );

  // 监听来自overlay的消息
  uiReceivePort.listen((msg) {
    debugPrint('Received from overlay: $msg');
    // 处理消息逻辑
  });
}

@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OverlayWindow(),
    ),
  );
}

/// 重启应用
void restartApp() async {
  // 注销所有热键
  await hotKeyManager.unregisterAll();

  if (Platform.isWindows) {
    await Process.start(
      Platform.resolvedExecutable,
      [restart],
    );
  }

  // 关闭应用
  closeApp();
}

/// 关闭应用
void closeApp() async {
  if (Platform.isWindows) {
    await windowManager.hide();

    // 停止相关isolate
    WindowsApp.autoTpModel.stop();
    stopToastListen();

    await systemTray.destroy();
    exit(0);
  }
}

/// 初始化应用
Future<void> _initApp() async {
  // 自定义存储路径
  final customPath = await getStoragePath();
  box = GetStorage(appId, customPath);
  // 初始化数据库
  await initDb();

  await initFileManagement();
  if (!kIsWeb &&
      [
        TargetPlatform.windows,
        TargetPlatform.android,
      ].contains(defaultTargetPlatform)) {
    SystemTheme.accentColor.load();
  }

  if (isDesktop) {
    await flutter_acrylic.Window.initialize();

    if (defaultTargetPlatform == TargetPlatform.windows) {
      await flutter_acrylic.Window.hideWindowControls();
    }
    await WindowManager.instance.ensureInitialized();
    windowManager.waitUntilReadyToShow().then((_) async {
      await windowManager.setIcon(getTrayImagePath('logo'));
      await windowManager.setTitleBarStyle(
        TitleBarStyle.hidden,
        windowButtonVisibility: false,
      );
      await windowManager.setSize(const Size(1200, 900));
      await windowManager.setMinimumSize(const Size(800, 600));
      await windowManager.setAlignment(Alignment.center);

      await windowManager.show();
      await windowManager.setPreventClose(true);
      await windowManager.setSkipTaskbar(false);

      runWin32EventIsolate();
      await runToastIsolate();
      startToastListen();
    });
  }
}

bool get isDesktop {
  if (kIsWeb) return false;
  return [
    TargetPlatform.windows,
    TargetPlatform.linux,
    TargetPlatform.macOS,
  ].contains(defaultTargetPlatform);
}
