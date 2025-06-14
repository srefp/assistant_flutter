import 'dart:ffi';
import 'dart:isolate';

import 'package:assistant/win32/mouse_listen.dart';
import 'package:easy_isolate/easy_isolate.dart';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

import '../key_mouse/keyboard_event.dart';
import '../key_mouse/mouse_event.dart';
import '../util/key_mouse_name.dart';
import '../win32/key_listen.dart';

late SendPort interpolatePort;
int eventHook = 0;
int keyHook = 0;
int mouseHook = 0;
int runNr = 0;
var worker = Worker();

const EVENT_SYSTEM_MOVESIZESTART = 0x000A;
const WINEVENT_OUTOFCONTEXT = 0x0000, WINEVENT_SKIPOWNPROCESS = 0x0002;
const EVENT_SYSTEM_MOVESIZEEND = 0x000B;

void runWin32EventIsolate() async {
  if (runNr != 0) {
    worker.dispose(immediate: true);
  }
  runNr++;
  worker = Worker();
  await worker.init(hookWin, hookIsolate);
  print("Worker restarted.. ${worker.hashCode}");
  worker.sendMessage(runNr);
}

void hookIsolate(
    dynamic data, SendPort mainSendPort, SendErrorFunction onSendError) {
  print(data);
  runNr = data;
  interpolatePort = mainSendPort;
  final hInstance = GetModuleHandle(nullptr);

  // 添加键盘钩子
  eventHook = SetWinEventHook(
      EVENT_SYSTEM_MOVESIZESTART,
      EVENT_SYSTEM_MOVESIZEEND,
      NULL,
      Pointer.fromFunction<EvHookFunc>(sysWinEventHook, 0),
      0,
      0,
      WINEVENT_OUTOFCONTEXT | WINEVENT_SKIPOWNPROCESS);

  // 添加鼠标钩子
  mouseHook = SetWindowsHookEx(WINDOWS_HOOK_ID.WH_MOUSE_LL,
      Pointer.fromFunction<HOOKPROC>(mouseBinding, 0), hInstance, 0);
  keyHook =
      SetWindowsHookEx(WINDOWS_HOOK_ID.WH_KEYBOARD_LL, keyFunc, hInstance, 0);
  final msg = calloc<MSG>();
  GetMessage(msg, NULL, 0, 0);
  print('运行结束');
  free(msg); // 释放内存
}

final keyFunc = Pointer.fromFunction<HOOKPROC>(keyboardBinding, 0);

void hookWin(dynamic event, SendPort isolateSendPort) async {
  if (event is RawKeyboardEvent) {
    KeyboardEvent keyboardEvent = event.toKeyboardEvent();

    // print(
    //     "M: ${keyboardEvent.name}, D: ${keyboardEvent.down}, M: ${keyboardEvent.modifiers}");
    keyboardListener(keyboardEvent);
  } else if (event is RawMouseEvent) {
    MouseEvent mouseEvent = event.toMouseEvent();
    // print(
    //     "M: ${mouseEvent.name}, D: ${mouseEvent.down}, T: ${mouseEvent.type} X: ${mouseEvent.x}, Y: ${mouseEvent.y}");
    mouseListener(mouseEvent);
  } else {
    print('收到其他消息: $event');
  }
}

bool closeEntrance = false;

int keyboardBinding(int code, int wParam, int lParam) {
  if (code == HC_ACTION) {
    final kbs = Pointer<KBDLLHOOKSTRUCT>.fromAddress(lParam);
    // if (kbs.ref.vkCode == VIRTUAL_KEY.VK_F8) {
    if (closeEntrance) {
      UnhookWindowsHookEx(eventHook);
      UnhookWindowsHookEx(keyHook);
      UnhookWindowsHookEx(mouseHook);
      PostQuitMessage(0);
      print('结束了');
    }
    interpolatePort.send(
        RawKeyboardEvent(kbs.ref.vkCode, wParam == WM_KEYDOWN, kbs.ref.flags));
  }
  return CallNextHookEx(keyHook, code, wParam, lParam);
}

// 新增鼠标事件处理函数
int mouseBinding(int code, int wParam, int lParam) {
  //忽略鼠标移动事件
  if (wParam != WM_MOUSEMOVE && code == HC_ACTION) {
    final mhs = Pointer<MSLLHOOKSTRUCT>.fromAddress(lParam);
    final event = RawMouseEvent(
      mhs.ref.pt.x,
      mhs.ref.pt.y,
      wParam,
      mhs.ref.mouseData,
    );
    interpolatePort.send(event);
  }
  return CallNextHookEx(mouseHook, code, wParam, lParam);
}

const xbutton1 = 0x0001;
const xbutton2 = 0x0002;

class RawMouseEvent {
  final int x;
  final int y;
  final int wParam;
  final int mouseData;

  RawMouseEvent(this.x, this.y, this.wParam, this.mouseData);

  MouseEvent toMouseEvent() {
    var name = 'left_button';
    var type = MouseEventType.leftButtonDown;
    var down = true;

    final highWord = HIWORD(mouseData);

    if (wParam == WM_LBUTTONDOWN) {
      name = 'left_button';
      type = MouseEventType.leftButtonDown;
      down = true;
    } else if (wParam == WM_LBUTTONUP) {
      name = 'left_button';
      type = MouseEventType.leftButtonUp;
      down = false;
    } else if (wParam == WM_XBUTTONDOWN) {
      final highWord = HIWORD(mouseData);
      if (highWord == xbutton1) {
        name = 'xbutton1';
        type = MouseEventType.x1ButtonDown;
      } else if (highWord == xbutton2) {
        name = 'xbutton2';
        type = MouseEventType.x2ButtonDown;
      }
      down = true;
    } else if (wParam == WM_XBUTTONUP) {
      final highWord = HIWORD(mouseData);
      if (highWord == xbutton1) {
        name = 'xbutton1';
        type = MouseEventType.x1ButtonUp;
      } else if (highWord == xbutton2) {
        name = 'xbutton2';
        type = MouseEventType.x2ButtonUp;
      }
      down = false;
    } else if (wParam == WM_RBUTTONDOWN) {
      name = 'right_button';
      type = MouseEventType.rightButtonDown;
      down = true;
    } else if (wParam == WM_RBUTTONUP) {
      name = 'right_button';
      type = MouseEventType.rightButtonUp;
      down = false;
    } else if (wParam == WM_MBUTTONDOWN) {
      name = 'middle_button';
      type = MouseEventType.middleButtonDown;
      down = true;
    } else if (wParam == WM_MBUTTONUP) {
      name = 'middle_button';
      type = MouseEventType.middleButtonUp;
      down = false;
    } else if (wParam == WM_MOUSEWHEEL) {
      name = highWord == 120 ? 'wheel_up' : 'wheel_down';
      type = highWord == 120 ? MouseEventType.wheelUp : MouseEventType.wheelDown;
      down = true;
    }

    return MouseEvent(x, y, name, down, type);
  }
}

class RawKeyboardEvent {
  final int vkCode;
  final bool down;
  final int flags;

  RawKeyboardEvent(this.vkCode, this.down, this.flags);

  KeyboardEvent toKeyboardEvent() {
    final name = getKeyName(vkCode);
    // 新增修饰键检测逻辑
    final modifiers = <String>[];

    // 使用GetAsyncKeyState检测Ctrl/Shift状态
    if (GetAsyncKeyState(VIRTUAL_KEY.VK_CONTROL) & 0x8000 != 0) {
      modifiers.add('ctrl');
    }
    if (GetAsyncKeyState(VIRTUAL_KEY.VK_MENU) & 0x8000 != 0) {
      modifiers.add('alt');
    }
    if (GetAsyncKeyState(VIRTUAL_KEY.VK_SHIFT) & 0x8000 != 0) {
      modifiers.add('shift');
    }

    bool mocked = flags & KBDLLHOOKSTRUCT_FLAGS.LLKHF_INJECTED != 0;

    return KeyboardEvent(name, down, mocked, modifiers);
  }
}

int sysWinEventHook(int hWinEventHook, int event, int hWnd, int idObject,
    int idChild, int idEventThread, int dwmsEventTime) {
  final length = GetWindowTextLength(hWnd);
  final title = wsalloc(length);
  GetWindowText(hWnd, title, length);
  free(title);
  return 1;
}

// #region (collapsed) [dlls]
final _user32 = DynamicLibrary.open('user32.dll');

typedef EvHookFunc = LRESULT Function(
    Int32 hWinEventHook,
    DWORD event,
    HWND hwnd,
    LONG idObject,
    LONG idChild,
    DWORD idEventThread,
    DWORD dwmsEventTime);
// ignore: non_constant_identifier_names
int SetWinEventHook(
        int eventMin,
        int eventMax,
        int hmodWinEventProc,
        Pointer<NativeFunction<EvHookFunc>> pfnWinEventProc,
        int idProcess,
        int idThread,
        int dwFlags) =>
    _SetWinEventHook(eventMin, eventMax, hmodWinEventProc, pfnWinEventProc,
        idProcess, idThread, dwFlags);

// ignore: non_constant_identifier_names
final _SetWinEventHook = _user32.lookupFunction<
    IntPtr Function(
        Uint32 eventMin,
        Uint32 eventMax,
        IntPtr hmodWinEventProc,
        Pointer<NativeFunction<EvHookFunc>> pfnWinEventProc,
        Uint32 idProcess,
        Uint32 idThread,
        Uint32 dwFlags),
    int Function(
        int eventMin,
        int eventMax,
        int hmodWinEventProc,
        Pointer<NativeFunction<EvHookFunc>> pfnWinEventProc,
        int idProcess,
        int idThread,
        int dwFlags)>('SetWinEventHook');
// #endregion
