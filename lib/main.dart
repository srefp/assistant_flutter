import 'package:assistant/app/windows_app.dart';
import 'package:assistant/util/db_helper.dart';
import 'package:assistant/util/path_manage.dart';
import 'package:fluent_ui/fluent_ui.dart' hide Page;
import 'package:flutter/foundation.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:get_storage/get_storage.dart';
import 'package:system_theme/system_theme.dart';
import 'package:window_manager/window_manager.dart';
import 'package:windows_single_instance/windows_single_instance.dart';

import 'config/config_storage.dart';
import 'isolate/win32_event_listen.dart';

const String version = '2025.6.16';
const String innerVersion = '2025.6.16';
const String appId = 'assistant';
const int versionCode = 1;
const String appTitle = '耕地机 v$version';
final DateTime outDate = DateTime(2025, 10, 1);

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kDebugMode) {
    await WindowsSingleInstance.ensureSingleInstance(args, appId);
  }
  await _initApp();

  runApp(const WindowsApp());
}

/// 初始化应用
Future<void> _initApp() async {
  // 自定义存储路径
  final customPath = await getStoragePath();
  box = GetStorage(appId, customPath);
  // 初始化数据库
  await initWindowsDb();

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
      await windowManager.setTitleBarStyle(
        TitleBarStyle.hidden,
        windowButtonVisibility: false,
      );
      await windowManager.setAlignment(Alignment.center);
      await windowManager.setSize(const Size(1200, 900));
      await windowManager.setMinimumSize(const Size(800, 600));

      await windowManager.show();
      await windowManager.setPreventClose(true);
      await windowManager.setSkipTaskbar(false);

      runWin32EventIsolate();
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
