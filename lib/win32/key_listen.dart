import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

typedef HookProc = int Function(int, int, int);
typedef ListenProc = int Function(Pointer);

Pointer<NativeFunction<HOOKPROC>> SetCallback(HookProc callback) {
  return NativeCallable<HOOKPROC>.isolateLocal(callback, exceptionalReturn: 0)
      .nativeFunction;
}

Pointer<NativeFunction<LPTHREAD_START_ROUTINE>> SetListenCallback(
    ListenProc callback) {
  return NativeCallable<LPTHREAD_START_ROUTINE>.isolateLocal(callback,
          exceptionalReturn: 0)
      .nativeFunction;
}

// 全局变量
int keyboardHook = 0;
final hookProcPointer = SetCallback((nCode, wParam, lParam) {
  int res = CallNextHookEx(keyboardHook, nCode, wParam, lParam);
  if (nCode >= 0) {
    final kbdStruct = Pointer<KBDLLHOOKSTRUCT>.fromAddress(lParam);
    final vkCode = kbdStruct.ref.vkCode;
    print(
        'Key event: ${wParam == WM_KEYDOWN ? 'Down' : 'Up'} | VK Code: $vkCode | Name: ${getKeyName(vkCode)}');
  }
  return res;
});

final threadProc = SetListenCallback((lpParam) {
  final msg = calloc<MSG>();
  while (GetMessage(msg, NULL, 0, 0) != 0) {
    TranslateMessage(msg);
    DispatchMessage(msg);
  }
  free(msg);
  return 0;
});

void startKeyboardHook() async {
  // 必须通过 GetModuleHandle 获取当前实例
  final hModule = GetModuleHandle(nullptr);

  keyboardHook = SetWindowsHookEx(
    WINDOWS_HOOK_ID.WH_KEYBOARD_LL, // 低级键鼠钩子
    hookProcPointer, // 回调函数指针
    hModule, // 模块句柄
    0, // 线程ID（0 表示全局）
  );

  if (keyboardHook == 0) {
    print('钩子安装失败: ${GetLastError()}');
    return;
  }

  // 必须运行消息循环
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

// 键码映射函数
String getKeyName(int vkCode) {
  switch (vkCode) {
    case VIRTUAL_KEY.VK_BACK:
      return 'Backspace';
    case VIRTUAL_KEY.VK_TAB:
      return 'Tab';
    case VIRTUAL_KEY.VK_RETURN:
      return 'Enter';
    case VIRTUAL_KEY.VK_ESCAPE:
      return 'Esc';
    case VIRTUAL_KEY.VK_SPACE:
      return 'Space';
    case VIRTUAL_KEY.VK_PRIOR:
      return 'PageUp';
    case VIRTUAL_KEY.VK_NEXT:
      return 'PageDown';
    case VIRTUAL_KEY.VK_END:
      return 'End';
    case VIRTUAL_KEY.VK_HOME:
      return 'Home';
    case VIRTUAL_KEY.VK_LEFT:
      return '←';
    case VIRTUAL_KEY.VK_UP:
      return '↑';
    case VIRTUAL_KEY.VK_RIGHT:
      return '→';
    case VIRTUAL_KEY.VK_DOWN:
      return '↓';
    case VIRTUAL_KEY.VK_DELETE:
      return 'Delete';
    case VIRTUAL_KEY.VK_CAPITAL:
      return 'CapsLock';
    case VIRTUAL_KEY.VK_SHIFT:
      return 'Shift';
    case VIRTUAL_KEY.VK_CONTROL:
      return 'Ctrl';
    case VIRTUAL_KEY.VK_MENU:
      return 'Alt';
    case VIRTUAL_KEY.VK_LWIN:
      return 'Win(Left)';
    case VIRTUAL_KEY.VK_RWIN:
      return 'Win(Right)';
    default:
    // 处理字母和数字（A-Z, 0-9）
      if (vkCode >= 0x30 && vkCode <= 0x39) { // 数字键 0-9
        return String.fromCharCode(vkCode);
      } else if (vkCode >= 0x41 && vkCode <= 0x5A) { // 字母 A-Z
        return String.fromCharCode(vkCode);
      } else if (vkCode >= 0x60 && vkCode <= 0x69) { // 小键盘数字
        return 'NumPad ${vkCode - 0x60}';
      }
      return '0x${vkCode.toRadixString(16).padLeft(2, '0')}';
  }
}
