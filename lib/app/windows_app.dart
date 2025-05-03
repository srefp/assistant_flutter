import 'dart:io';

import 'package:assistant/app/root_app.dart';
import 'package:assistant/components/log_view_wrapper.dart';
import 'package:assistant/components/win_text.dart';
import 'package:assistant/config/verification_config.dart';
import 'package:assistant/main.dart';
import 'package:assistant/notifier/doc_model.dart';
import 'package:assistant/notifier/log_model.dart';
import 'package:assistant/notifier/script_editor_model.dart';
import 'package:assistant/screens/config_page.dart';
import 'package:assistant/screens/doc_page.dart';
import 'package:assistant/screens/record_page.dart';
import 'package:assistant/util/hot_key.dart';
import 'package:dio/dio.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import '../notifier/app_model.dart';
import '../notifier/auto_tp_model.dart';
import '../notifier/config_model.dart';
import '../notifier/script_record_model.dart';
import '../routes/routes.dart';
import '../screens/auto_tp.dart';
import '../screens/script_editor.dart';
import '../screens/settings.dart';
import '../screens/test.dart';
import '../theme.dart';

class WindowsApp extends StatefulWidget {
  const WindowsApp({super.key});

  static final autoTpModel = AutoTpModel();
  static final scriptEditorModel = ScriptEditorModel();
  static final logModel = LogModel();
  static final recordModel = ScriptRecordModel();
  static final appModel = AppModel();
  static final configModel = ConfigModel();
  static final docModel = DocModel();

  @override
  State<WindowsApp> createState() => _WindowsAppState();
}

final _appTheme = AppTheme();

class _WindowsAppState extends State<WindowsApp>
    with TrayListener, WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    trayManager.addListener(this);
    _initSystemTray();
    initHotKey();
    // verifyClient();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    trayManager.removeListener(this);
    super.dispose();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose && mounted) {
      windowManager.hide();
    }
  }

  _getProviders() {
    return [
      // APP配置
      ChangeNotifierProvider(
        create: (context) => WindowsApp.appModel,
      ),

      // 配置
      ChangeNotifierProvider(
        create: (context) => WindowsApp.configModel,
      ),

      // 自动传送
      ChangeNotifierProvider(
        create: (context) => WindowsApp.autoTpModel,
      ),

      // 日志
      ChangeNotifierProvider(
        create: (context) => WindowsApp.logModel,
      ),

      // 脚本编辑器
      ChangeNotifierProvider(
        create: (context) => WindowsApp.scriptEditorModel,
      ),

      // 键盘录制器
      ChangeNotifierProvider(
        create: (context) => WindowsApp.recordModel,
      ),

      // 文档
      ChangeNotifierProvider(
        create: (context) => WindowsApp.docModel,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: _getProviders(),
      child: ChangeNotifierProvider.value(
        value: _appTheme,
        builder: (context, child) {
          final appTheme = context.watch<AppTheme>();
          return FluentApp.router(
            title: appTitle,
            themeMode: appTheme.mode,
            debugShowCheckedModeBanner: false,
            color: appTheme.color,
            darkTheme: FluentThemeData(
              brightness: Brightness.dark,
              accentColor: appTheme.color,
              visualDensity: VisualDensity.standard,
              focusTheme: FocusThemeData(
                glowFactor: is10footScreen(context) ? 2.0 : 0.0,
              ),
            ),
            theme: FluentThemeData(
              accentColor: appTheme.color,
              visualDensity: VisualDensity.standard,
              focusTheme: FocusThemeData(
                glowFactor: is10footScreen(context) ? 2.0 : 0.0,
              ),
              fontFamily: fontFamily,
            ),
            locale: appTheme.locale,
            builder: (context, child) {
              return Directionality(
                textDirection: appTheme.textDirection,
                child: NavigationPaneTheme(
                  data: NavigationPaneThemeData(
                    backgroundColor: appTheme.windowEffect !=
                            flutter_acrylic.WindowEffect.disabled
                        ? Colors.transparent
                        : null,
                  ),
                  child: child!,
                ),
              );
            },
            routeInformationParser: router.routeInformationParser,
            routerDelegate: router.routerDelegate,
            routeInformationProvider: router.routeInformationProvider,
          );
        },
      ),
    );
  }

  void _initSystemTray() async {
    await trayManager.setIcon(
      Platform.isWindows ? 'assets/image/logo.ico' : 'assets/image/logo.png',
    );
    Menu menu = Menu(
      items: [
        MenuItem(
          key: 'show_window',
          label: 'Show Window',
          onClick: (item) {
            windowManager.show();
          },
        ),
        MenuItem.separator(),
        MenuItem(
          key: 'exit_app',
          label: 'Exit App',
          onClick: (item) {
            windowManager.hide();
            trayManager.destroy();
            windowManager.destroy();
          },
        ),
      ],
    );
    await trayManager.setContextMenu(menu);
  }

  /// 验证客户端
  void verifyClient() {
    var response = Dio().get(VerificationConfig.to.verificationServer());
    print(response);
  }
}

final rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();
final router = GoRouter(navigatorKey: rootNavigatorKey, routes: [
  ShellRoute(
    navigatorKey: _shellNavigatorKey,
    builder: (context, state, child) {
      return RootApp(
        shellContext: _shellNavigatorKey.currentContext,
        child: child,
      );
    },
    routes: <GoRoute>[
      /// Auto Tp
      GoRoute(
          path: Routes.autoTp, builder: (context, state) => const AutoTpPage()),

      /// Script Editor
      GoRoute(
        path: Routes.scriptEditor,
        builder: (context, state) => const LogViewWrapper(
          child: ScriptEditor(),
        ),
      ),

      /// Record
      GoRoute(
          path: Routes.record, builder: (context, state) => const RecordPage()),

      /// Config
      GoRoute(
          path: Routes.config, builder: (context, state) => const ConfigPage()),

      /// Doc
      GoRoute(path: Routes.doc, builder: (context, state) => const DocPage()),

      /// Test
      GoRoute(path: Routes.test, builder: (context, state) => const Test()),

      /// Settings
      GoRoute(
          path: Routes.settings, builder: (context, state) => const Settings()),
    ],
  ),
]);
