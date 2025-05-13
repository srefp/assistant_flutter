import 'dart:async';
import 'dart:ffi';

import 'package:assistant/auto_gui/key_mouse_util.dart';
import 'package:assistant/auto_gui/keyboard.dart';
import 'package:assistant/config/auto_tp_config.dart';
import 'package:assistant/config/hotkey_config.dart';
import 'package:assistant/config/record_config.dart';
import 'package:assistant/constants/script_type.dart';
import 'package:assistant/executor/route_executor.dart';
import 'package:assistant/manager/screen_manager.dart';
import 'package:assistant/notifier/log_model.dart';
import 'package:assistant/win32/toast.dart';
import 'package:win32/win32.dart';

import '../app/windows_app.dart';

typedef HookProc = int Function(int, int, int);
typedef ListenProc = int Function(Pointer);

Pointer<NativeFunction<HOOKPROC>> setCallback(HookProc callback) {
  return NativeCallable<HOOKPROC>.isolateLocal(callback, exceptionalReturn: 0)
      .nativeFunction;
}

Pointer<NativeFunction<LPTHREAD_START_ROUTINE>> setListenCallback(
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
final hookProcPointer = setCallback((nCode, wParam, lParam) {
  int res = CallNextHookEx(keyboardHook, nCode, wParam, lParam);
  if (nCode >= 0) {
    final kbdStruct = Pointer<KBDLLHOOKSTRUCT>.fromAddress(lParam);
    final vkCode = kbdStruct.ref.vkCode;
    // print(
    //     'Key event: ${wParam == WM_KEYDOWN ? 'Down' : 'Up'} | VK Code: $vkCode | Name: ${getKeyName(vkCode)}');

    // 添加事件来源判断（0x10表示程序注入事件）
    if ((kbdStruct.ref.flags & 0x10) != 0) {
      // print('是模拟事件，跳过');
      return res;
    }

    if (WindowsApp.autoTpModel.isRunning &&
        ScreenManager.instance.isGameActive()) {
      listenKeyboard(vkCode, wParam);
    }

    if (WindowsApp.recordModel.isRecording) {
      if (WindowsApp.scriptEditorModel.selectedScriptType == autoTp) {
        recordRoute(vkCode, wParam);
      } else {
        recordScript(vkCode, wParam);
      }
    }
  }
  return res;
});

/// 监听操作
void listenKeyboard(int vkCode, int wParam) async {
  final keyName = getKeyName(vkCode);
  quickPick(vkCode, wParam, keyName);
  dash(vkCode, wParam, keyName);
  recordFood(vkCode, wParam, keyName);

  if (wParam != WM_KEYDOWN) {
    return;
  }

  if (keyName == RecordConfig.to.getNextKey()) {
    RouteExecutor.tpNext(false);
  }

  if (keyName == HotkeyConfig.to.getShowCoordsKey()) {
    KeyMouseUtil.showCoordinate();
  }

  if (keyName == '0xc0') {
    eatFood();
  }
}

bool foodSelected = false;

void eatFood() async {
  showToast('记录完成');
  foodRecording = false;

  if (foodRecordTimer != null) {
    foodRecordTimer?.cancel();
    foodRecordTimer = null;
  }

  api.keyDown(key: 'b');
  await Future.delayed(Duration(milliseconds: 20));
  api.keyUp(key: 'b');
  await Future.delayed(Duration(milliseconds: 600));

  if (!foodSelected) {
    await KeyMouseUtil.clickAtPoint(AutoTpConfig.to.getFoodPosIntList(), 120);
    foodSelected = true;
  }

  var foodList = AutoTpConfig.to.getRecordedFoodPosList();
  for (var index = 0; index < foodList.length; index += 2) {
    var foodPos = [foodList[index], foodList[index + 1]];
    await KeyMouseUtil.clickAtPoint(foodPos, 60);
    await KeyMouseUtil.clickAtPoint(AutoTpConfig.to.getConfirmPosIntList(), 60);
  }
}

int lastBPressTime = 0;
const double keyDoubleClickThreshold = 500;

bool foodRecording = false;
Timer? foodRecordTimer;

void recordFood(int vkCode, int wParam, String keyName) async {
  if (keyName == AutoTpConfig.to.getFoodKey()) {
    if (wParam == WM_KEYDOWN) {
      int currentTime = DateTime.now().millisecondsSinceEpoch;
      if (currentTime - lastBPressTime < keyDoubleClickThreshold) {
        // 点击食物
        await Future.delayed(Duration(milliseconds: 600), () async {
          await KeyMouseUtil.clickAtPoint(AutoTpConfig.to.getFoodPosIntList(), 100);
          foodSelected = true;
        });

        foodRecording = true;
        AutoTpConfig.to.save(AutoTpConfig.keyRecordedFoodPos, '');
        WindowsApp.autoTpModel.fresh();

        showToast('食品列表已清空，你有20秒的时间来记录食物坐标');

        if (foodRecordTimer != null) {
          foodRecordTimer?.cancel();
          foodRecordTimer = null;
        }

        foodRecordTimer ??= Timer(Duration(seconds: 20), () {
          showToast('记录完成');
          foodRecording = false;
        });
      }
      lastBPressTime = currentTime;
    }
  }
}

// 添加全局定时器变量
Timer? _fKeyTimer;

/// 快捡
void quickPick(int vkCode, int wParam, String keyName) {
  if (!AutoTpConfig.to.isQuickPickEnabled()) {
    return;
  }

  if (keyName == HotkeyConfig.to.getQuickPickKey()) {
    if (wParam == WM_KEYDOWN) {
      _fKeyTimer ??= Timer.periodic(Duration(milliseconds: 20), (timer) async {
        // 后面可以判断按键是否按下：!(GetKeyState(VIRTUAL_KEY.VK_F) & 0x8000 != 0)
        if (!WindowsApp.autoTpModel.isRunning ||
            !ScreenManager.instance.isGameActive()) {
          _fKeyTimer?.cancel();
          _fKeyTimer = null;
          return;
        }
        api.keyDown(key: HotkeyConfig.to.getQuickPickKey());
        await Future.delayed(Duration(milliseconds: 5));
        api.keyUp(key: HotkeyConfig.to.getQuickPickKey());
        await Future.delayed(Duration(milliseconds: 5));
        api.scroll(clicks: -1);
      });
    } else if (wParam == WM_KEYUP) {
      _fKeyTimer?.cancel();
      _fKeyTimer = null;
    }
  }
}

/// 匀速冲刺定时器
Timer? _dashTimer;

void dash(int vkCode, int wParam, String keyName) {
  if (!AutoTpConfig.to.isDashEnabled()) {
    return;
  }

  final shiftPressed = GetKeyState(VIRTUAL_KEY.VK_SHIFT) & 0x8000 != 0;

  if (shiftPressed && keyName == 'w' && wParam == WM_KEYDOWN) {
    _dashTimer ??= Timer.periodic(Duration(milliseconds: 860), (timer) async {
      if (!WindowsApp.autoTpModel.isRunning ||
          !ScreenManager.instance.isGameActive()) {
        _dashTimer?.cancel();
        _dashTimer = null;
        return;
      }

      api.keyDown(key: 'shift');
      await Future.delayed(Duration(milliseconds: 20));
      api.keyUp(key: 'shift');
    });
  } else if (keyName == 'w' && wParam == WM_KEYUP) {
    _dashTimer?.cancel();
    _dashTimer = null;
  }
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
