import 'dart:io';

import 'package:assistant/components/win_text.dart';
import 'package:assistant/main.dart';
import 'package:assistant/util/hot_key.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;

import '../routes/routes.dart';
import '../screens/auto_tp.dart';
import '../screens/script_editor.dart';
import '../screens/settings.dart';
import '../screens/ssh_operation.dart';
import '../screens/test.dart';
import '../theme.dart';

class WindowsApp extends StatefulWidget {
  const WindowsApp({super.key});

  @override
  State<WindowsApp> createState() => _WindowsAppState();
}

final _appTheme = AppTheme();

class _WindowsAppState extends State<WindowsApp> with TrayListener {
  @override
  void initState() {
    super.initState();
    trayManager.addListener(this);
    _initSystemTray();
    initHotKey();
  }

  @override
  void dispose() {
    trayManager.removeListener(this);
    super.dispose();
  }

  @override
  void onTrayIconRightMouseDown() {
    // do something, for example pop up the menu
    trayManager.popUpContextMenu();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
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
    );

  }

  void _initSystemTray() async{
    await trayManager.setIcon(
      Platform.isWindows
          ? 'assets/image/logo.ico'
          : 'assets/image/logo.png',
    );
    Menu menu = Menu(
      items: [
        MenuItem(
          key: 'show_window',
          label: 'Show Window',
          onClick: (item){
            windowManager.show();
          },
        ),
        MenuItem.separator(),
        MenuItem(
          key: 'exit_app',
          label: 'Exit App',
          onClick: (item){
            windowManager.hide();
            trayManager.destroy();
            windowManager.destroy();
          },
        ),
      ],
    );
    await trayManager.setContextMenu(menu);
  }
}

final rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();
final router = GoRouter(navigatorKey: rootNavigatorKey, routes: [
  ShellRoute(
    navigatorKey: _shellNavigatorKey,
    builder: (context, state, child) {
      return MyHomePage(
        shellContext: _shellNavigatorKey.currentContext,
        child: child,
      );
    },
    routes: <GoRoute>[
      /// Auto Tp
      GoRoute(
          path: Routes.autoTp, builder: (context, state) => const AutoTpPage()),

      /// SSH Operation
      GoRoute(
          path: Routes.sshOperation,
          builder: (context, state) => const SshOperation()),

      /// SSH Operation
      GoRoute(
          path: Routes.scriptEditor,
          builder: (context, state) => const ScriptEditor()),

      /// Test
      GoRoute(
          path: Routes.test,
          builder: (context, state) => const Test()),

      /// Settings
      GoRoute(
          path: Routes.settings, builder: (context, state) => const Settings()),
    ],
  ),
]);

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.child,
    required this.shellContext,
  });

  final Widget child;
  final BuildContext? shellContext;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WindowListener {
  bool value = false;
  final viewKey = GlobalKey(debugLabel: 'Navigation View Key');
  final searchKey = GlobalKey(debugLabel: 'Search Bar Key');
  final searchFocusNode = FocusNode();
  final searchController = TextEditingController();

  late final List<NavigationPaneItem> originalItems = [
    PaneItem(
      key: const ValueKey(Routes.autoTp),
      icon: const Icon(FluentIcons.rocket),
      title: Text(
        '自动传送',
        style: TextStyle(fontFamily: fontFamily),
      ),
      body: const SizedBox.shrink(),
      onTap: () {
        if (GoRouterState.of(context).uri.toString() != Routes.autoTp) {
          context.go(Routes.autoTp);
        }
      },
    ),
    // PaneItem(
    //   key: const ValueKey(Routes.sshOperation),
    //   icon: const Icon(FluentIcons.connect_virtual_machine),
    //   title: Text(
    //     'SSH连接',
    //     style: TextStyle(fontFamily: fontFamily),
    //   ),
    //   body: const SizedBox.shrink(),
    //   onTap: () {
    //     if (GoRouterState.of(context).uri.toString() != Routes.sshOperation) {
    //       context.go(Routes.sshOperation);
    //     }
    //   },
    // ),
    PaneItem(
      key: const ValueKey(Routes.scriptEditor),
      icon: const Icon(FluentIcons.code_edit),
      title: Text(
        '脚本',
        style: TextStyle(fontFamily: fontFamily),
      ),
      body: const SizedBox.shrink(),
      onTap: () {
        if (GoRouterState.of(context).uri.toString() != Routes.scriptEditor) {
          context.go(Routes.scriptEditor);
        }
      },
    ),
    PaneItem(
      key: const ValueKey(Routes.test),
      icon: const Icon(FluentIcons.test_case),
      title: Text(
        '测试',
        style: TextStyle(fontFamily: fontFamily),
      ),
      body: const SizedBox.shrink(),
      onTap: () {
        if (GoRouterState.of(context).uri.toString() != Routes.test) {
          context.go(Routes.test);
        }
      },
    ),
  ];

  late final List<NavigationPaneItem> footerItems = [
    PaneItemSeparator(),
    PaneItem(
      key: const ValueKey(Routes.settings),
      icon: const Icon(FluentIcons.settings),
      title: Text(
        '设置',
        style: TextStyle(fontFamily: fontFamily),
      ),
      body: const SizedBox.shrink(),
      onTap: () {
        if (GoRouterState.of(context).uri.toString() != Routes.settings) {
          context.go(Routes.settings);
        }
      },
    ),
  ];

  @override
  void initState() {
    windowManager.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    int indexOriginal = originalItems
        .where((item) => item.key != null)
        .toList()
        .indexWhere((item) => item.key == Key(location));

    if (indexOriginal == -1) {
      int indexFooter = footerItems
          .where((element) => element.key != null)
          .toList()
          .indexWhere((element) => element.key == Key(location));
      if (indexFooter == -1) {
        return 0;
      }
      return originalItems
          .where((element) => element.key != null)
          .toList()
          .length +
          indexFooter;
    } else {
      return indexOriginal;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.shellContext != null) {
      if (router.canPop() == false) {
        setState(() {});
      }
    }
    return NavigationView(
      key: viewKey,
      appBar: NavigationAppBar(
        automaticallyImplyLeading: false,
        height: 50,

        title: () {
          if (kIsWeb) {
            return const Align(
              alignment: AlignmentDirectional.centerStart,
              child: WinText(appTitle),
            );
          }
          return DragToMoveArea(
            child: SizedBox(
              height: 50,
              child: Row(
                children: [
                  SizedBox(width: 14),
                  SvgPicture.asset(
                    'assets/image/logo.svg',
                    height: 18,
                  ),
                  SizedBox(width: 8),
                  const WinText(appTitle, style: TextStyle(fontSize: 13),),
                ],
              ),
            ),
          );
        }(),
        actions: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          if (!kIsWeb) const WindowButtons(),
        ]),
      ),
      paneBodyBuilder: (item, child) {
        final name =
        item?.key is ValueKey ? (item!.key as ValueKey).value : null;
        return FocusTraversalGroup(
          key: ValueKey('body$name'),
          child: widget.child,
        );
      },
      pane: NavigationPane(
        selected: _calculateSelectedIndex(context),
        displayMode: PaneDisplayMode.compact,
        items: originalItems,
        autoSuggestBox: Builder(builder: (context) {
          return AutoSuggestBox(
            key: searchKey,
            focusNode: searchFocusNode,
            controller: searchController,
            unfocusedColor: Colors.transparent,
            items: <PaneItem>[
              ...originalItems
                  .whereType<PaneItemExpander>()
                  .expand<PaneItem>((item) {
                return [
                  item,
                  ...item.items.whereType<PaneItem>(),
                ];
              }),
              ...originalItems
                  .where(
                    (item) => item is PaneItem && item is! PaneItemExpander,
              )
                  .cast<PaneItem>(),
            ].map((item) {
              final text = (item.title as Text).data!;
              return AutoSuggestBoxItem(
                label: text,
                child: WinText(text),
                value: text,
                onSelected: () {
                  item.onTap?.call();
                  searchController.clear();
                  searchFocusNode.unfocus();
                  final view = NavigationView.of(context);
                  if (view.compactOverlayOpen) {
                    view.compactOverlayOpen = false;
                  } else if (view.minimalPaneOpen) {
                    view.minimalPaneOpen = false;
                  }
                },
              );
            }).toList(),
            trailingIcon: IgnorePointer(
              child: IconButton(
                onPressed: () {},
                icon: const Icon(FluentIcons.search),
              ),
            ),
            placeholder: '搜索',
            style: TextStyle(fontFamily: fontFamily),
          );
        }),
        autoSuggestBoxReplacement: const Icon(FluentIcons.search),
        footerItems: footerItems,
      ),
      onOpenSearch: searchFocusNode.requestFocus,
    );
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose && mounted) {
      windowManager.hide();
    }
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final FluentThemeData theme = FluentTheme.of(context);

    return SizedBox(
      width: 138,
      height: 36,
      child: WindowCaption(
        brightness: theme.brightness,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
