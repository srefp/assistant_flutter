import 'dart:async';

import 'package:assistant/helper/cv/scan.dart';
import 'package:assistant/helper/helper.dart';
import 'package:assistant/helper/win32/toast.dart';

import '../../app/config/auto_tp_config.dart';
import '../../app/config/config_storage.dart';
import '../../app/config/hotkey_config.dart';
import '../../app/config/process_key_config.dart';
import '../../app/config/process_pos/process_pos_config.dart';
import '../../app/windows_app.dart';
import '../auto_gui/key_mouse_util.dart';
import '../auto_gui/operations.dart';
import '../executor/route_executor.dart';
import '../key_mouse/event_type.dart';
import '../key_mouse/keyboard_event.dart';
import 'key_mouse_listen.dart';

void keyboardListener(KeyboardEvent event) {
  if (!WindowsApp.autoTpModel.active()) {
    return;
  }

  if (event.name == ProcessKeyConfig.to.getOpenMapKey() && event.down) {
    final detect = !AutoTpConfig.to.isDetectWhenMock() || !event.mocked;

    if (detect) {
      startWorldDetect();
      appLog.info('开始检测大世界');
    }
  }

  if (event.mocked && !AutoTpConfig.to.isAllowMockKey()) {
    return;
  }

  keyMouseListen(EventType.keyboard, event.toString(), event.down, []);
}

/// 监听键鼠操作
void listenAll(String name, bool down) async {
  quickPick(name, down);
  timerDash(name, down);
  recordFood(name, down);

  if (!down) {
    return;
  }

  // print('name: $name');

  if (AutoTpConfig.to.isAutoTpEnabled() &&
      name == HotkeyConfig.to.getTpNext()) {
    RouteExecutor.tpNext(false);
  } else if (HotkeyConfig.to.isToggleRecordEnabled() &&
      name == HotkeyConfig.to.getToggleRecordKey()) {
    toggleRecord();
  } else if (HotkeyConfig.to.isShowCoordsEnabled() &&
      name == HotkeyConfig.to.getShowCoordsKey()) {
    KeyMouseUtil.showCoordinate();
  } else if (name == HotkeyConfig.to.getToggleQuickPickKey()) {
    if (AutoTpConfig.to.isToggleQuickPickEnabled()) {
      final quickPickEnabled = AutoTpConfig.to.isQuickPickEnabled();
      box.write(AutoTpConfig.keyQuickPickEnabled, !quickPickEnabled);
      showToast('${quickPickEnabled ? '关闭' : '开启'}快捡');
    }
  } else if (name == HotkeyConfig.to.getEatFoodKey()) {
    eatFood();
  } else if (HotkeyConfig.to.isToPrevEnabled() &&
      name == HotkeyConfig.to.getToPrev()) {
    RouteExecutor.toPrev();
  } else if (HotkeyConfig.to.isToNextEnabled() &&
      name == HotkeyConfig.to.getToNext()) {
    RouteExecutor.toNext();
  } else if (HotkeyConfig.to.isHalfTpEnabled() &&
      name == HotkeyConfig.to.getHalfTp()) {
    executeTpc();
  } else if (HotkeyConfig.to.isQmAutoTpEnabled() &&
      name == HotkeyConfig.to.getQmTpNext()) {
    RouteExecutor.tpNext(true);
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

  api.keyDown(key: ProcessKeyConfig.to.getBagKey());
  await Future.delayed(Duration(milliseconds: 20));
  api.keyUp(key: ProcessKeyConfig.to.getBagKey());
  await Future.delayed(
      Duration(milliseconds: AutoTpConfig.to.getOpenBagDelay()));

  if (!foodSelected) {
    await KeyMouseUtil.clickAtPoint(
        ProcessPosConfig.to.getFoodPosIntList(), 120);
    foodSelected = true;
  }

  var foodList = AutoTpConfig.to.getRecordedFoodPosList();
  for (var index = 0; index < foodList.length; index += 2) {
    var foodPos = [foodList[index], foodList[index + 1]];
    await KeyMouseUtil.clickAtPoint(
        foodPos, AutoTpConfig.to.getClickFoodDelay());
    await KeyMouseUtil.clickAtPoint(ProcessPosConfig.to.getConfirmPosIntList(),
        AutoTpConfig.to.getEatFoodDelay());
  }

  api.keyDown(key: ProcessKeyConfig.to.getBagKey());
  await Future.delayed(Duration(milliseconds: 20));
  api.keyUp(key: ProcessKeyConfig.to.getBagKey());

  await Future.delayed(Duration(milliseconds: 300));
}

int lastBPressTime = 0;
const double keyDoubleClickThreshold = 350;

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
              ProcessPosConfig.to.getFoodPosIntList(), 100);
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
      _fKeyTimer ??= Timer.periodic(
          Duration(milliseconds: AutoTpConfig.to.getPickTotalDelay()),
          (timer) async {
        // 后面可以判断按键是否按下：!(GetKeyState(VIRTUAL_KEY.VK_F) & 0x8000 != 0)
        if (!WindowsApp.autoTpModel.active()) {
          _fKeyTimer?.cancel();
          _fKeyTimer = null;
          return;
        }
        api.keyDown(key: ProcessKeyConfig.to.getPickKey());
        await Future.delayed(
            Duration(milliseconds: AutoTpConfig.to.getPickDownDelay()));
        api.keyUp(key: ProcessKeyConfig.to.getPickKey());
        await Future.delayed(
            Duration(milliseconds: AutoTpConfig.to.getPickUpDelay()));
        api.scroll(clicks: -1);
      });
    } else {
      _fKeyTimer?.cancel();
      _fKeyTimer = null;
    }
  }
}

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

  if (name == ProcessKeyConfig.to.getForwardKey() && down) {
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
      api.keyDown(key: ProcessKeyConfig.to.getForwardKey());
      _dashTimer ??= Timer.periodic(
          Duration(milliseconds: AutoTpConfig.to.getDashIntervalDelay()),
          (timer) async {
        if (!WindowsApp.autoTpModel.active()) {
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
  final dashKey = ProcessKeyConfig.to.getDashKey();
  await api.keyDown(key: dashKey);
  await Future.delayed(Duration(milliseconds: 20));
  await api.keyUp(key: dashKey);
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

void toggleRecord() {}
