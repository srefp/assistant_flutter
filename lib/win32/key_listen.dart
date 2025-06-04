import 'dart:async';
import 'dart:ffi';

import 'package:assistant/auto_gui/key_mouse_util.dart';
import 'package:assistant/auto_gui/keyboard.dart';
import 'package:assistant/config/auto_tp_config.dart';
import 'package:assistant/config/game_key_config.dart';
import 'package:assistant/config/hotkey_config.dart';
import 'package:assistant/executor/route_executor.dart';
import 'package:assistant/manager/screen_manager.dart';
import 'package:assistant/notifier/log_model.dart';
import 'package:assistant/win32/toast.dart';
import 'package:flutter/services.dart';
import 'package:hid_listener/hid_listener.dart';
import 'package:win32/win32.dart';

import '../app/windows_app.dart';
import '../config/game_pos/game_pos_config.dart';
import '../util/key_mouse_name.dart';
import 'key_mouse_listen.dart';

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

void keyboardListener(RawKeyEvent event) {
  final data = event.data;

  if (!WindowsApp.autoTpModel.isRunning ||
      !ScreenManager.instance.isGameActive()) {
    return;
  }

  if (data is KeyExt) {
    KeyExt eventData = data;
    if (eventData.mocked) {
      return;
    }

    final bool down = event is RawKeyDownEvent;
    final keyName = getKeyName(data.keyCode);

    keyMouseListen(keyName, down);
  }
}

/// 监听操作
void listenKeyboard(String name, bool down) async {
  quickPick(name, down);
  timerDash(name, down);
  recordFood(name, down);

  if (!down) {
    return;
  }

  if (name == HotkeyConfig.to.getTpNext()) {
    RouteExecutor.tpNext(false);
  }

  if (name == HotkeyConfig.to.getShowCoordsKey()) {
    KeyMouseUtil.showCoordinate();
  }

  if (name == HotkeyConfig.to.getEatFoodKey()) {
    eatFood();
  }
}

bool foodSelected = false;

bool eatFoodForbidden = false;

void eatFood() async {
  if (!AutoTpConfig.to.isEatFoodEnabled()) {
    return;
  }

  if (eatFoodForbidden) {
    return;
  }

  eatFoodForbidden = true;

  Timer(Duration(seconds: 1), () {
    eatFoodForbidden = false;
  });

  if (foodRecording) {
    showToast('记录完成');
    foodRecording = false;
  }

  if (foodRecordTimer != null) {
    foodRecordTimer?.cancel();
    foodRecordTimer = null;
  }

  api.keyDown(key: GameKeyConfig.to.getBagKey());
  await Future.delayed(Duration(milliseconds: 20));
  api.keyUp(key: GameKeyConfig.to.getBagKey());
  await Future.delayed(
      Duration(milliseconds: AutoTpConfig.to.getOpenBagDelay()));

  if (!foodSelected) {
    await KeyMouseUtil.clickAtPoint(GamePosConfig.to.getFoodPosIntList(), 120);
    foodSelected = true;
  }

  var foodList = AutoTpConfig.to.getRecordedFoodPosList();
  for (var index = 0; index < foodList.length; index += 2) {
    var foodPos = [foodList[index], foodList[index + 1]];
    await KeyMouseUtil.clickAtPoint(
        foodPos, AutoTpConfig.to.getClickFoodDelay());
    await KeyMouseUtil.clickAtPoint(GamePosConfig.to.getConfirmPosIntList(),
        AutoTpConfig.to.getEatFoodDelay());
  }

  api.keyDown(key: GameKeyConfig.to.getBagKey());
  await Future.delayed(Duration(milliseconds: 20));
  api.keyUp(key: GameKeyConfig.to.getBagKey());

  await Future.delayed(Duration(milliseconds: 300));
}

int lastBPressTime = 0;
const double keyDoubleClickThreshold = 300;

bool foodRecording = false;
Timer? foodRecordTimer;

void recordFood(String name, bool down) async {
  if (!AutoTpConfig.to.isFoodRecordEnabled()) {
    return;
  }

  if (name == AutoTpConfig.to.getFoodKey()) {
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    if (foodRecording &&
        down &&
        currentTime - lastBPressTime > keyDoubleClickThreshold) {
      showToast('记录完成');
      foodRecording = false;
      foodRecordTimer?.cancel();
      foodRecordTimer = null;
    }

    if (down) {
      int currentTime = DateTime.now().millisecondsSinceEpoch;
      if (currentTime - lastBPressTime < keyDoubleClickThreshold) {
        // 点击食物
        await Future.delayed(
            Duration(
              milliseconds: AutoTpConfig.to.getOpenBagDelay(),
            ), () async {
          await KeyMouseUtil.clickAtPoint(
              GamePosConfig.to.getFoodPosIntList(), 100);
          foodSelected = true;
        });

        foodRecording = true;
        AutoTpConfig.to.save(AutoTpConfig.keyRecordedFoodPos, '');
        WindowsApp.autoTpModel.fresh();

        showToast('食品列表已清空，请通过鼠标点击记录食物坐标');

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
void quickPick(String name, bool down) {
  if (!AutoTpConfig.to.isQuickPickEnabled()) {
    return;
  }

  if (name == HotkeyConfig.to.getQuickPickKey()) {
    if (down) {
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
    } else {
      _fKeyTimer?.cancel();
      _fKeyTimer = null;
    }
  }
}

/// 全局快捡
Timer? _globalQuickPickTimer;

/// 全局快捡
void globalQuickPick(String name, bool down) {
  if (!AutoTpConfig.to.isGlobalQuickPickEnabled()) {
    return;
  }
}

/// 匀速冲刺定时器
Timer? _dashTimer;

/// 定时冲刺
void timerDash(String name, bool down) async {
  if (!AutoTpConfig.to.isDashEnabled()) {
    return;
  }

  if (name == GameKeyConfig.to.getForwardKey() && down) {
    if (_dashTimer != null) {
      showToast('停止冲刺');
      _dashTimer?.cancel();
      _dashTimer = null;
    }
  }

  if (name != HotkeyConfig.to.getTimerDashKey()) {
    return;
  }

  if (down) {
    if (_dashTimer != null) {
      showToast('停止冲刺');
      _dashTimer?.cancel();
      _dashTimer = null;
    } else {
      showToast('开始冲刺');
      await dash();
      api.keyDown(key: GameKeyConfig.to.getForwardKey());
      _dashTimer ??= Timer.periodic(Duration(milliseconds: AutoTpConfig.to.getDashIntervalDelay()), (timer) async {
        if (!WindowsApp.autoTpModel.isRunning ||
            !ScreenManager.instance.isGameActive()) {
          _dashTimer?.cancel();
          _dashTimer = null;
          return;
        }

        await dash();
      });
    }
  }
}

Future<void> dash() async {
  final dashKey = GameKeyConfig.to.getDashKey();
  await api.keyDown(key: dashKey);
  await Future.delayed(Duration(milliseconds: 20));
  await api.keyUp(key: dashKey);
}

/// 记录路线
void recordRoute(String name, bool down) {
  WindowsApp.logModel.appendDelay(WindowsApp.recordModel.getDelay());

  // 开图键录制
  if (name != GameKeyConfig.to.getOpenMapKey()) {
    return;
  }

  final operation = down ? 'kDown' : 'kUp';
  WindowsApp.logModel.appendOperation(
      Operation(func: operation, template: "$operation('$name', %s);"));
}

/// 记录脚本
void recordScript(String name, bool down) {
  WindowsApp.logModel.appendDelay(WindowsApp.recordModel.getDelay());
  WindowsApp.logModel.outputAsScript();

  if (name == 'left') {
    simulateMouseMove('left');
    WindowsApp.logModel.outputAsScript();
    WindowsApp.logModel
        .append('moveR3D(${directionDistances['left']}, 10, 5);');
  } else if (name == 'up') {
    simulateMouseMove('up');
    WindowsApp.logModel.outputAsScript();
    WindowsApp.logModel.append('moveR3D(${directionDistances['up']}, 10, 5);');
  } else if (name == 'right') {
    simulateMouseMove('right');
    WindowsApp.logModel.outputAsScript();
    WindowsApp.logModel
        .append('moveR3D(${directionDistances['right']}, 10, 5);');
  } else if (name == 'down') {
    simulateMouseMove('down');
    WindowsApp.logModel.outputAsScript();
    WindowsApp.logModel
        .append('moveR3D(${directionDistances['down']}, 10, 5);');
  } else {
    final func = down ? 'kDown' : 'kUp';
    WindowsApp.logModel.appendOperation(Operation(
      func: func,
      template: "$func('$name', %s);",
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
