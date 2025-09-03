import 'dart:io';

import 'package:assistant/app/root_app.dart';
import 'package:assistant/helper/key_mouse/hot_key.dart';
import 'package:assistant/main.dart';
import 'package:dio/dio.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import '../component/text/win_text.dart';
import '../component/theme.dart';
import '../helper/windows/tray.dart';
import 'config/auto_tp_config.dart';
import 'config/env_config.dart';
import 'config/verification_config.dart';
import 'module/app/app_model.dart';
import 'module/auto_tp/auto_tp_model.dart';
import 'module/auto_tp/auto_tp_page.dart';
import 'module/capture/capture_model.dart';
import 'module/capture/capture_page.dart';
import 'module/code_gen/code_gen_model.dart';
import 'module/config/config_model.dart';
import 'module/doc/doc_model.dart';
import 'module/doc/doc_page.dart';
import 'module/efficient/efficient_model.dart';
import 'module/efficient/efficient_page.dart';
import 'module/macro/macro_edit_page.dart';
import 'module/macro/macro_model.dart';
import 'module/macro/macro_page.dart';
import 'module/pic/pic_edit_page.dart';
import 'module/record/record_model.dart';
import 'module/record/record_page.dart';
import 'module/screens/tool_page.dart';
import 'module/script/script_editor_model.dart';
import 'module/script/script_editor_page.dart';
import 'module/script/script_model.dart';
import 'module/script/script_page.dart';
import 'module/setting/settings.dart';
import 'module/test/test_page.dart';
import 'routes.dart';

class WindowsApp extends StatefulWidget {
  const WindowsApp({super.key});

  static final autoTpModel = AutoTpModel();
  static final scriptEditorModel = ScriptEditorModel();
  static final logModel = RecordModel.instance;
  static final appModel = AppModel();
  static final configModel = ConfigModel();
  static final docModel = DocModel();
  static final scriptManagementModel = ScriptManagementModel();
  static final captureManagementModel = PicModel();
  static final macroModel = MacroModel();
  static final efficientModel = EfficientModel();
  static final codeGenModel = CodeGenModel();

  @override
  State<WindowsApp> createState() => _WindowsAppState();
}

final _appTheme = AppTheme();

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class _WindowsAppState extends State<WindowsApp> with WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    if (Platform.isWindows) {
      if (AutoTpConfig.to.isTrayEnabled()) {
        initSystemTray();
      }
      initHotKey();
    }
    // verifyClient();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowClose() async {
    if (!AutoTpConfig.to.isTrayEnabled()) {
      closeApp();
      return;
    }

    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose && mounted && AutoTpConfig.to.isTrayEnabled()) {
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

      // 脚本管理
      ChangeNotifierProvider(
        create: (context) => WindowsApp.scriptManagementModel,
      ),

      // 截图管理
      ChangeNotifierProvider(
        create: (context) => WindowsApp.captureManagementModel,
      ),

      // 宏
      ChangeNotifierProvider(
        create: (context) => WindowsApp.macroModel,
      ),

      // 效率
      ChangeNotifierProvider(
        create: (context) => WindowsApp.efficientModel,
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

  /// 验证客户端
  void verifyClient() {
    Dio().get(VerificationConfig.to.verificationServer());
  }
}

final rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();
final router = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: Env.initialRoute,
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return RootApp(
          shellContext: _shellNavigatorKey.currentContext,
          child: child,
        );
      },
      routes: _buildRoutes(),
    ),
  ],
);

_buildRoutes() {
  final routes = <GoRoute>[
    /// Auto Tp
    GoRoute(
        path: Routes.autoTp, builder: (context, state) => const AutoTpPage()),

    /// Script Editor
    GoRoute(
      path: Routes.scriptEditor,
      builder: (context, state) => const ScriptEditor(),
    ),

    /// Script Management
    GoRoute(
        path: Routes.scriptManagement,
        builder: (context, state) => const ScriptManagementPage()),

    /// Capture Management
    GoRoute(
        path: Routes.pic,
        builder: (context, state) => const CaptureManagementPage()),

    /// Pic Edit
    GoRoute(
        path: Routes.picEdit, builder: (context, state) => const PicEditPage()),

    /// Macro
    GoRoute(path: Routes.macro, builder: (context, state) => const MacroPage()),

    /// Macro Edit
    GoRoute(
        path: Routes.macroEdit,
        builder: (context, state) => const MacroEditPage()),

    /// Record
    GoRoute(
        path: Routes.record, builder: (context, state) => const RecordPage()),

    /// Doc
    GoRoute(path: Routes.doc, builder: (context, state) => const DocPage()),

    /// Efficient
    GoRoute(
        path: Routes.efficient,
        builder: (context, state) => const EfficientPage()),
  ];

  if (Env.showTools) {
    routes.add(
      GoRoute(
        path: Routes.tool,
        builder: (context, state) => const ToolPage(),
      ),
    );
  }
  if (Env.showTest) {
    routes.add(
      GoRoute(path: Routes.test, builder: (context, state) => const Test()),
    );
  }

  /// Settings
  routes.add(GoRoute(
      path: Routes.settings, builder: (context, state) => const Settings()));
  return routes;
}
