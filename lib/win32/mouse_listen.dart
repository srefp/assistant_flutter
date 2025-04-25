import 'dart:ffi';

import 'package:assistant/auto_gui/key_mouse_util.dart';
import 'package:assistant/config/record_config.dart';
import 'package:assistant/util/half_tp.dart';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

import '../app/windows_app.dart';
import '../notifier/log_model.dart';

typedef HookProc = int Function(int, int, int);
typedef ListenProc = int Function(Pointer);

// 获取鼠标事件类型描述
String _getMouseEventType(int msg) {
  return const {
        WM_LBUTTONDOWN: '左键按下',
        WM_LBUTTONUP: '左键释放',
        WM_RBUTTONDOWN: '右键按下',
        WM_RBUTTONUP: '右键释放',
        WM_MOUSEMOVE: '鼠标移动',
        WM_MOUSEWHEEL: '滚轮滚动',
        WM_XBUTTONDOWN: '鼠标X键按下',
      }[msg] ??
      '未知事件';
}

Pointer<NativeFunction<HOOKPROC>> SetCallback(HookProc callback) {
  return NativeCallable<HOOKPROC>.isolateLocal(callback, exceptionalReturn: 0)
      .nativeFunction;
}

int getXButtonWParam(int wParam) {
  // 提取高字部分 (高 16 位)
  return (wParam >> 16) & 0xFFFF;
}

const XBUTTON1 = 0x0001;
const XBUTTON2 = 0x0002;

// 全局钩子变量
int mouseHook = 0;
final hookProcPointer = SetCallback((nCode, wParam, lParam) {
  final result = CallNextHookEx(mouseHook, nCode, wParam, lParam);

  // 过滤鼠标移动事件
  if (wParam == WM_MOUSEMOVE) {
    return result;
  }

  if (nCode >= 0) {
    final mouseStruct = Pointer<MSLLHOOKSTRUCT>.fromAddress(lParam);

//     print('''
// 鼠标事件: ${eventDesc.padRight(8)}
// 坐标: (${mouseStruct.ref.pt.x}, ${mouseStruct.ref.pt.y})
// 时间: ${mouseStruct.ref.time}
// ''');

    if (WindowsApp.scriptEditorModel.selectedDir == '自动传') {
      recordRoute(mouseStruct, wParam, lParam);
    } else {
      recordScript(mouseStruct, wParam, lParam);
    }
  }
  return result;
});

void recordRoute(Pointer<MSLLHOOKSTRUCT> mouseStruct, int wParam, int lParam) {
  final mouseData = mouseStruct.ref.mouseData;
  final xButton = (mouseData >> 16) & 0xFFFF; // 高位字
  List<int> coords =
      KeyMouseUtil.logicalPos([mouseStruct.ref.pt.x, mouseStruct.ref.pt.y]);

  if (xButton == XBUTTON2 && wParam == WM_XBUTTONDOWN) {
    tpc();

    WindowsApp.logModel.appendOperation(Operation(
        func: "tpc",
        template:
            "tpc('slow', [${coords[0]}, ${coords[1]}], 0});"));

    WindowsApp.logModel.outputAsRoute();
  }

  int delay = WindowsApp.recordModel.getDelay();
  WindowsApp.logModel.appendDelay(delay);

  switch (wParam) {
    case WM_LBUTTONDOWN:
      WindowsApp.logModel.appendOperation(Operation(
          func: 'mDown',
          coords: coords,
          template: 'mDown([${coords[0]}, ${coords[1]}], %s);',
          prevDelay: delay));
      break;
    case WM_LBUTTONUP:
      WindowsApp.logModel.appendOperation(Operation(
          func: 'mUp',
          coords: coords,
          template: 'mUp([${coords[0]}, ${coords[1]}], %s);',
          prevDelay: delay));
      break;
    case WM_RBUTTONDOWN:
      WindowsApp.logModel.appendOperation(Operation(
          func: 'mDownRight',
          coords: coords,
          template: "mDown('right', '[${coords[0]}, ${coords[1]}], %s);",
          prevDelay: delay));
      break;
    case WM_RBUTTONUP:
      WindowsApp.logModel.appendOperation(Operation(
          func: 'mUpRight',
          coords: coords,
          template: "mUp('right', '[${coords[0]}, ${coords[1]}], %s);",
          prevDelay: delay));
      break;
    case WM_MOUSEWHEEL:
      final mouseStruct = Pointer<MSLLHOOKSTRUCT>.fromAddress(lParam);
      final wheelDelta = HIWORD(mouseStruct.ref.mouseData);
      WindowsApp.logModel.appendOperation(Operation(
          func: 'wheel',
          template: "wheel(${wheelDelta > 32768 ? 1 : -1}, %s);",
          prevDelay: delay));
      break;
  }
}

void recordScript(Pointer<MSLLHOOKSTRUCT> mouseStruct, int wParam, int lParam) {
  List<int> coords =
      KeyMouseUtil.logicalPos([mouseStruct.ref.pt.x, mouseStruct.ref.pt.y]);

  int delay = WindowsApp.recordModel.getDelay();

  WindowsApp.logModel.appendDelay(delay);
  WindowsApp.logModel.outputAsScript();

  switch (wParam) {
    case WM_LBUTTONDOWN:
      WindowsApp.logModel.appendOperation(Operation(
          func: 'mDown',
          coords: coords,
          template: 'mDown([${coords[0]}, ${coords[1]}], %s);',
          prevDelay: delay));
      break;
    case WM_LBUTTONUP:
      WindowsApp.logModel.appendOperation(Operation(
          func: 'mUp',
          coords: coords,
          template: 'mUp([${coords[0]}, ${coords[1]}], %s);',
          prevDelay: delay));
      break;
    case WM_RBUTTONDOWN:
      WindowsApp.logModel.appendOperation(Operation(
          func: 'mDownRight',
          coords: coords,
          template: "mDown('right', '[${coords[0]}, ${coords[1]}], %s);",
          prevDelay: delay));
      break;
    case WM_RBUTTONUP:
      WindowsApp.logModel.appendOperation(Operation(
          func: 'mUpRight',
          coords: coords,
          template: "mUp('right', '[${coords[0]}, ${coords[1]}], %s);",
          prevDelay: delay));
      break;
    case WM_MOUSEWHEEL:
      final mouseStruct = Pointer<MSLLHOOKSTRUCT>.fromAddress(lParam);
      final wheelDelta = HIWORD(mouseStruct.ref.mouseData);
      WindowsApp.logModel.appendOperation(Operation(
          func: 'wheel',
          template: "wheel(${wheelDelta > 32768 ? 1 : -1}, %s);",
          prevDelay: delay));
      break;
  }
}

/// 停止鼠标监听
void stopMouseHook() {
  if (mouseHook != 0) {
    UnhookWindowsHookEx(mouseHook);
    mouseHook = 0;
  }
}

/// 启动鼠标监听
void startMouseHook() async {
  final hModule = GetModuleHandle(nullptr);

  mouseHook = SetWindowsHookEx(
    WINDOWS_HOOK_ID.WH_MOUSE_LL, // 改为鼠标钩子类型
    hookProcPointer,
    hModule,
    0,
  );

  if (mouseHook == 0) {
    WindowsApp.logModel.append('鼠标钩子安装失败: ${GetLastError()}');
    return;
  }

  // 非阻塞消息循环（与键盘监听相同）
  final msg = calloc<MSG>();
  await Future.doWhile(() async {
    await Future.delayed(const Duration(milliseconds: 1));
    while (
        PeekMessage(msg, NULL, 0, 0, PEEK_MESSAGE_REMOVE_TYPE.PM_REMOVE) != 0) {
      TranslateMessage(msg);
      DispatchMessage(msg);
    }
    return true;
  });
  free(msg);
}
