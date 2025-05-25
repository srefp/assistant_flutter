import 'dart:ffi';

import 'package:assistant/auto_gui/system_control.dart';
import 'package:assistant/config/auto_tp_config.dart';
import 'package:win32/win32.dart';

import '../app/windows_app.dart';
import '../win32/models.dart';
import '../win32/task_manager.dart';

// 窗口事件常量
const eventSystemMoveSizeEnd = 0x000B;
const eventObjectDestroy = 0x8001;
const winEventOutOfContext = 0x0000;
const winEventSkipOwnProcess = 0x0002;

// 添加以下函数声明
final _user32 = DynamicLibrary.open('user32.dll');

typedef WinEventProc = Void Function(
  IntPtr hWinEventHook,
  Uint32 event,
  IntPtr hwnd,
  Int32 idObject,
  Int32 idChild,
  Uint32 dwEventThread,
  Uint32 dwmsEventTime,
);
typedef WinEventProcDart = void Function(
  int hWinEventHook,
  int event,
  int hwnd,
  int idObject,
  int idChild,
  int dwEventThread,
  int dwmsEventTime,
);

final setWinEventHook = _user32.lookupFunction<
    IntPtr Function(
        Uint32 eventMin,
        Uint32 eventMax,
        IntPtr hmodWinEventProc,
        Pointer<NativeFunction<WinEventProc>> lpfnWinEventProc,
        Uint32 idProcess,
        Uint32 idThread,
        Uint32 dwFlags),
    int Function(
        int eventMin,
        int eventMax,
        int hmodWinEventProc,
        Pointer<NativeFunction<WinEventProc>> lpfnWinEventProc,
        int idProcess,
        int idThread,
        int dwFlags)>('SetWinEventHook');

final unhookWinEvent = _user32.lookupFunction<
    Int32 Function(IntPtr hWinEventHook),
    int Function(int hWinEventHook)>('UnhookWinEvent');

class ScreenManager {
  static ScreenManager? _instance;

  int _hook = 0; // 添加事件钩子引用

  static ScreenManager get instance {
    _instance ??= ScreenManager._internal();
    return _instance!;
  }

  // 添加窗口事件监听
  void startListen() {
    _hook = setWinEventHook(
        eventSystemMoveSizeEnd,
        // 窗口移动/调整大小事件
        eventObjectDestroy,
        // 窗口销毁事件
        0,
        Pointer.fromFunction(_winEventProc),
        0,
        0,
        winEventOutOfContext | winEventSkipOwnProcess);
  }

  // 窗口事件回调处理
  static void _winEventProc(int hWinEventHook, int event, int hwnd,
      int idObject, int idChild, int dwEventThread, int dwmsEventTime) {
    final instance = ScreenManager.instance;
    // 仅处理目标窗口的事件
    if (hwnd != instance.hWnd) return;

    switch (event) {
      case eventSystemMoveSizeEnd:
        instance.refreshWindowHandle();

        // 触发窗口移动后，重新计算窗口矩形
        SystemControl.refreshRect();
        break;
      case eventObjectDestroy:
        instance.hWnd = 0;

        // 触发窗口关闭后的处理
        WindowsApp.autoTpModel.stop();
        break;
    }
  }

  ScreenManager._internal();

  int hWnd = 0;

  /// 判断窗口是否存在
  bool isWindowExist() {
    return hWnd != 0;
  }

  refreshWindowHandle() {
    final tasks = TaskManager.tasks;
    hWnd = findWindowHandle(tasks);
  }

  /// 判断游戏窗口是否置顶
  bool isGameActive() {
    var hWnd = GetForegroundWindow();
    return hWnd == ScreenManager.instance.hWnd;
  }

  int findWindowHandle(final List<Task>? tasks) {
    Task? task;
    for (var value in AutoTpConfig.to.windowTitles) {
      task = findWindowByTitle(value, tasks);

      if (task != null) {
        break;
      }
    }

    if (task == null) {
      return 0;
    }

    int? mainHandle = TaskManager.getMainHandle(task.pid);
    return mainHandle ?? 0;
  }

  // 根据进程名称查找窗口句柄
  Task? findWindowByTitle(String windowTitle, final List<Task>? currentTasks) {
    final tasks = currentTasks ?? [];
    for (Task task in tasks) {
      if (task.name.contains(windowTitle)) {
        return task;
      }
    }
    return null;
  }
}
