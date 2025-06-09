import 'package:assistant/components/win_text.dart';
import 'package:assistant/app/windows_app.dart';
import 'package:assistant/notifier/app_model.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import '../config/setting_config.dart';
import '../main.dart';
import '../routes/routes.dart';

const double iconSize = 16;

class RootApp extends StatefulWidget {
  const RootApp({
    super.key,
    required this.child,
    required this.shellContext,
  });

  final Widget child;
  final BuildContext? shellContext;

  @override
  State<RootApp> createState() => _RootAppState();
}

class _RootAppState extends State<RootApp> {
  bool value = false;
  final viewKey = GlobalKey(debugLabel: 'Navigation View Key');
  final searchKey = GlobalKey(debugLabel: 'Search Bar Key');
  final searchFocusNode = FocusNode();
  final searchController = TextEditingController();

  List<NavigationPaneItem> get originalItems {
    final routes = <NavigationPaneItem>[];
    if (SettingConfig.to.getAutoTpMenu()) {
      routes.add(PaneItem(
        key: const ValueKey(Routes.autoTp),
        icon: const Icon(FluentIcons.rocket, size: iconSize),
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
      ));
    }

    if (SettingConfig.to.getScriptMenu()) {
      routes.add(PaneItem(
        key: const ValueKey(Routes.scriptEditor),
        icon: const Icon(FluentIcons.code_edit, size: iconSize),
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
      ));
    }

    if (SettingConfig.to.getRecordMenu()) {
      routes.add(PaneItem(
        key: const ValueKey(Routes.record),
        icon: const Icon(FluentIcons.record_routing, size: iconSize),
        title: Text(
          '记录',
          style: TextStyle(fontFamily: fontFamily),
        ),
        body: const SizedBox.shrink(),
        onTap: () {
          if (GoRouterState.of(context).uri.toString() != Routes.record) {
            context.go(Routes.record);
          }
        },
      ));
    }

    if (SettingConfig.to.getHotkeyMenu()) {
      routes.add(PaneItem(
        key: const ValueKey(Routes.config),
        icon: const Icon(FluentIcons.keyboard_classic, size: iconSize),
        title: Text(
          '快捷键',
          style: TextStyle(fontFamily: fontFamily),
        ),
        body: const SizedBox.shrink(),
        onTap: () {
          if (GoRouterState.of(context).uri.toString() != Routes.config) {
            context.go(Routes.config);
          }
        },
      ));
    }

    if (SettingConfig.to.getDocMenu()) {
      routes.add(PaneItem(
        key: const ValueKey(Routes.doc),
        icon: const Icon(FluentIcons.file_h_t_m_l, size: iconSize),
        title: Text(
          '文档',
          style: TextStyle(fontFamily: fontFamily),
        ),
        body: const SizedBox.shrink(),
        onTap: () {
          if (GoRouterState
              .of(context)
              .uri
              .toString() != Routes.doc) {
            context.go(Routes.doc);
          }
        },
      ));
    }

    if (SettingConfig.to.getToolMenu()) {
      routes.add(PaneItem(
        key: const ValueKey(Routes.tool),
        icon: const Icon(FluentIcons.toolbox, size: iconSize),
        title: Text(
          '工具',
          style: TextStyle(fontFamily: fontFamily),
        ),
        body: const SizedBox.shrink(),
        onTap: () {
          if (GoRouterState
              .of(context)
              .uri
              .toString() != Routes.tool) {
            context.go(Routes.tool);
          }
        },
      ));
    }

    if (SettingConfig.to.getTestMenu()) {
      routes.add(PaneItem(
        key: const ValueKey(Routes.test),
        icon: const Icon(FluentIcons.test_case, size: iconSize),
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
      ));
    }
    return routes;
  }

  late final List<NavigationPaneItem> footerItems = [
    PaneItemSeparator(),
    PaneItem(
      key: const ValueKey(Routes.settings),
      icon: const Icon(FluentIcons.settings, size: iconSize),
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
  void dispose() {
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
    return Consumer<AppModel>(builder: (context, model, child) {
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
                    const WinText(
                      appTitle,
                      style: TextStyle(fontSize: 13),
                    ),
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
                  icon: const Icon(FluentIcons.search, size: iconSize),
                ),
              ),
              placeholder: '搜索',
              style: TextStyle(fontFamily: fontFamily),
            );
          }),
          autoSuggestBoxReplacement: const Icon(FluentIcons.search, size: iconSize),
          footerItems: footerItems,
        ),
        onOpenSearch: searchFocusNode.requestFocus,
      );
    });
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
