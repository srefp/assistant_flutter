import 'dart:ffi';

import 'package:assistant/auto_gui/key_mouse_util.dart';
import 'package:assistant/config/record_config.dart';
import 'package:assistant/manager/screen_manager.dart';
import 'package:assistant/notifier/log_model.dart';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

import '../app/windows_app.dart';

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

const left = 37;
const up = 38;
const right = 39;
const down = 40;

// 全局变量
int keyboardHook = 0;
final hookProcPointer = SetCallback((nCode, wParam, lParam) {
  int res = CallNextHookEx(keyboardHook, nCode, wParam, lParam);
  if (nCode >= 0) {
    final kbdStruct = Pointer<KBDLLHOOKSTRUCT>.fromAddress(lParam);
    final vkCode = kbdStruct.ref.vkCode;
    // print(
    //     'Key event: ${wParam == WM_KEYDOWN ? 'Down' : 'Up'} | VK Code: $vkCode | Name: ${getKeyName(vkCode)}');

    if (WindowsApp.autoTpModel.isRunning && ScreenManager.instance.isGameActive()) {
      listenKeyboard(vkCode, wParam);
    }

    if (WindowsApp.recordModel.isRecording) {
      if (WindowsApp.scriptEditorModel.selectedDir == '自动传') {
        recordRoute(vkCode, wParam);
      } else {
        recordScript(vkCode, wParam);
      }
    }
  }
  return res;
});

/// 监听操作
void listenKeyboard(int vkCode, int wParam) {
  if (wParam != WM_KEYDOWN) {
    return;
  }
  final keyName = getKeyName(vkCode);
  if (keyName == RecordConfig.to.getNextKey()) {
    tpNext();
  }
}

void tpNext() {
}

/// 记录路线
void recordRoute(int vkCode, int wParam) {
  WindowsApp.logModel.appendDelay(WindowsApp.recordModel.getDelay());

  var key = getKeyName(vkCode);

  // 开图键录制
  if (key == RecordConfig.to.getOpenMapKey() && wParam == WM_KEYDOWN) {
    final operation = wParam == WM_KEYDOWN ? 'kDown' : 'kUp';
    WindowsApp.logModel.appendOperation(Operation(
        func: operation, template: "$operation('${getKeyName(vkCode)}', %s);"));
  } else {
    final operation = wParam == WM_KEYDOWN ? 'kDown' : 'kUp';
    WindowsApp.logModel.appendOperation(Operation(
        func: operation, template: "$operation('${getKeyName(vkCode)}', %s);"));
  }
}

/// 记录脚本
void recordScript(int vkCode, int wParam) {
  WindowsApp.logModel.appendDelay(WindowsApp.recordModel.getDelay());
  WindowsApp.logModel.outputAsScript();

  if (vkCode == left) {
    simulateMouseMove('left');
    WindowsApp.logModel.outputAsScript();
    WindowsApp.logModel
        .append('moveR3D(${directionDistances['left']}, 10, 5);');
  } else if (vkCode == up) {
    simulateMouseMove('up');
    WindowsApp.logModel.outputAsScript();
    WindowsApp.logModel.append('moveR3D(${directionDistances['up']}, 10, 5);');
  } else if (vkCode == right) {
    simulateMouseMove('right');
    WindowsApp.logModel.outputAsScript();
    WindowsApp.logModel
        .append('moveR3D(${directionDistances['right']}, 10, 5);');
  } else if (vkCode == down) {
    simulateMouseMove('down');
    WindowsApp.logModel.outputAsScript();
    WindowsApp.logModel
        .append('moveR3D(${directionDistances['down']}, 10, 5);');
  } else {
    final func = wParam == WM_KEYDOWN ? 'kDown' : 'kUp';
    WindowsApp.logModel.appendOperation(Operation(
      func: func,
      template: "$func('${getKeyName(vkCode)}', %s);",
    ));
  }
}

const dist = 20;

const directionDistances = {
  'left': [-dist, 0],
  'up': [0, -dist],
  'right': [dist, 0],
  'down': [0, dist],
};

void simulateMouseMove(String key) async {
  final distance = directionDistances[key] ?? [0, 0];
  await KeyMouseUtil.moveR3D(distance, 10, 5);
}

void simulateConfirmOperation() async {
  final confirmPosition = RecordConfig.to.getConfirmPosition();
  await KeyMouseUtil.clickAtPoint(confirmPosition);
}

final threadProc = SetListenCallback((lpParam) {
  final msg = calloc<MSG>();
  while (GetMessage(msg, NULL, 0, 0) != 0) {
    TranslateMessage(msg);
    DispatchMessage(msg);
  }
  free(msg);
  return 0;
});

/// 关闭键盘监听
void stopKeyboardHook() {
  if (keyboardHook != 0) {
    UnhookWindowsHookEx(keyboardHook);
    keyboardHook = 0;
  }
}

/// 启动键盘监听
void startKeyboardHook() async {
  if (keyboardHook != 0) {
    return;
  }

  // 必须通过 GetModuleHandle 获取当前实例
  final hModule = GetModuleHandle(nullptr);

  keyboardHook = SetWindowsHookEx(
    WINDOWS_HOOK_ID.WH_KEYBOARD_LL, // 低级键鼠钩子
    hookProcPointer, // 回调函数指针
    hModule, // 模块句柄
    0, // 线程ID（0 表示全局）
  );

  if (keyboardHook == 0) {
    WindowsApp.logModel.append('钩子安装失败: ${GetLastError()}');
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
      return 'backspace';
    case VIRTUAL_KEY.VK_TAB:
      return 'tab';
    case VIRTUAL_KEY.VK_RETURN:
      return 'enter';
    case VIRTUAL_KEY.VK_ESCAPE:
      return 'esc';
    case VIRTUAL_KEY.VK_SPACE:
      return 'space';
    case VIRTUAL_KEY.VK_PRIOR:
      return 'pageup';
    case VIRTUAL_KEY.VK_NEXT:
      return 'pagedown';
    case VIRTUAL_KEY.VK_END:
      return 'end';
    case VIRTUAL_KEY.VK_HOME:
      return 'home';
    case VIRTUAL_KEY.VK_LEFT:
      return 'left';
    case VIRTUAL_KEY.VK_UP:
      return 'up';
    case VIRTUAL_KEY.VK_RIGHT:
      return 'right';
    case VIRTUAL_KEY.VK_DOWN:
      return 'down';
    case VIRTUAL_KEY.VK_DELETE:
      return 'delete';
    case VIRTUAL_KEY.VK_CAPITAL:
      return 'capsLock';
    case VIRTUAL_KEY.VK_SHIFT:
      return 'shift';
    case VIRTUAL_KEY.VK_CONTROL:
      return 'ctrl';
    case VIRTUAL_KEY.VK_MENU:
      return 'alt';
    case VIRTUAL_KEY.VK_LWIN:
      return 'win(Left)';
    case VIRTUAL_KEY.VK_RWIN:
      return 'win(Right)';
    default:
      // 处理字母和数字（A-Z, 0-9）
      if (vkCode >= 0x30 && vkCode <= 0x39) {
        // 数字键 0-9
        return String.fromCharCode(vkCode);
      } else if (vkCode >= 0x41 && vkCode <= 0x5A) {
        // 字母 A-Z
        return String.fromCharCode(vkCode).toLowerCase();
      } else if (vkCode >= 0x60 && vkCode <= 0x69) {
        // 小键盘数字
        return 'NumPad ${vkCode - 0x60}';
      }
      return '0x${vkCode.toRadixString(16).padLeft(2, '0')}';
  }
}
