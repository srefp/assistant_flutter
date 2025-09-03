import 'dart:io';

import 'package:assistant/helper/windows/window_utils.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';

import '../../main.dart';

final SystemTray systemTray = SystemTray();

/// 初始化系统托盘
Future<void> initSystemTray() async {
  // 首先初始化systray菜单，然后添加菜单项
  await systemTray.initSystemTray(iconPath: getTrayImagePath('logo'));
  systemTray.setToolTip('耕地机');

  // 处理托盘事件
  systemTray.registerSystemTrayEventHandler((eventName) {
    if (eventName == kSystemTrayEventClick) {
      Platform.isWindows ? showOrHide() : systemTray.popUpContextMenu();
    } else if (eventName == kSystemTrayEventRightClick) {
      Platform.isWindows ? systemTray.popUpContextMenu() : showOrHide();
    }
  });

  await menuMain.buildFrom([
    MenuItemLabel(
      label: '显示',
      onClicked: (menuItem) {
        showWindow();
      },
    ),
    MenuItemLabel(
      label: '隐藏',
      onClicked: (menuItem) {
        windowManager.hide();
      },
    ),
    MenuItemLabel(
      label: '退出',
      onClicked: (menuItem) {
        closeApp();
      },
    ),
  ]);

  systemTray.setContextMenu(menuMain);
}

void showOrHide() async {
  if (await windowManager.isVisible()) {
    windowManager.hide();
  } else {
    showWindow();
  }
}

/// 显示窗口
void showWindow() async {
  await windowManager.show();
}

final Menu menuMain = Menu();
