import 'dart:ffi';
import 'dart:io';

import 'package:assistant/app/config/auto_tp_config.dart';
import 'package:assistant/app/module/auto_tp/auto_tp_model.dart';
import 'package:assistant/helper/toast/message_pump_helper.dart';
import 'package:win32/win32.dart';

import '../win32/models.dart';
import '../win32/task_manager.dart';
import '../win32/window.dart';

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

/// 鼠标事件
final mouseEvent = _user32.lookupFunction<
    Void Function(Uint32 dwFlags, Uint32 dx, Uint32 dy, Uint32 dwData,
        UintPtr dwExtraInfo),
    void Function(int dwFlags, int dx, int dy, int dwData,
        int dwExtraInfo)>('mouse_event');

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

  static ScreenManager get instance {
    _instance ??= ScreenManager._internal();
    return _instance!;
  }

  ScreenManager._internal();

  Task? task;

  int foregroundWindowHandle = 0;

  int get hWnd => AutoTpConfig.to.getValidType() == windowHandle
      ? foregroundWindowHandle
      : (task?.hWnd ?? 0);

  /// 判断窗口是否存在
  bool isWindowExist() {
    return hWnd != 0;
  }

  refreshWindowHandle({String? windowTitle}) {
    final tasks = TaskManager.tasks;

    if (windowTitle != null) {
      task = findTargetTask(windowTitle, tasks);
    }

    if (hWnd == 0) {
      // 添加窗口丢失处理
      stopListenWindow();
    }
  }

  /// 判断进程窗口是否置顶
  bool isWindowActive() {
    var hWnd = GetForegroundWindow();
    if (ScreenManager.instance.hWnd == 0) {
      return true;
    }
    return hWnd == ScreenManager.instance.hWnd;
  }

  static List<Task> getWindowTasks() {
    if (!Platform.isWindows) {
      return [];
    }
    final tasks = TaskManager.tasks ?? [];
    for (final task in tasks) {
      int? mainHandle = TaskManager.getMainHandle(task.pid);
      task.hWnd = mainHandle;
    }
    return tasks.where((task) => task.hWnd != null).toList();
  }

  Task? findTargetTask(final String windowTitle, final List<Task>? tasks) {
    Task? task;

    task = findWindowByTitle(windowTitle, tasks);

    if (task == null) {
      return null;
    }

    int? mainHandle = TaskManager.getMainHandle(task.pid);
    task.hWnd = mainHandle;
    if (mainHandle != null) {
      task.windowName = getWindowTitle(mainHandle);
    }
    return task;
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
