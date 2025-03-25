import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

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
  }[msg] ?? '未知事件';
}

Pointer<NativeFunction<HOOKPROC>> SetCallback(HookProc callback) {
  return NativeCallable<HOOKPROC>.isolateLocal(callback, exceptionalReturn: 0)
      .nativeFunction;
}

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
    final eventDesc = _getMouseEventType(wParam);

    print('''
鼠标事件: ${eventDesc.padRight(8)} 
坐标: (${mouseStruct.ref.pt.x}, ${mouseStruct.ref.pt.y}) 
时间: ${mouseStruct.ref.time}
''');
  }
  return result;
});

void startMouseHook() async {
  final hModule = GetModuleHandle(nullptr);

  mouseHook = SetWindowsHookEx(
    WINDOWS_HOOK_ID.WH_MOUSE_LL, // 改为鼠标钩子类型
    hookProcPointer,
    hModule,
    0,
  );

  if (mouseHook == 0) {
    print('鼠标钩子安装失败: ${GetLastError()}');
    return;
  }

  // 非阻塞消息循环（与键盘监听相同）
  final msg = calloc<MSG>();
  await Future.doWhile(() async {
    await Future.delayed(const Duration(milliseconds: 1));
    while (PeekMessage(msg, NULL, 0, 0, PEEK_MESSAGE_REMOVE_TYPE.PM_REMOVE) != 0) {
      TranslateMessage(msg);
      DispatchMessage(msg);
    }
    return true;
  });
  free(msg);
}
