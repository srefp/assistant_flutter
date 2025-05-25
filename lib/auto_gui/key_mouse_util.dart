import 'dart:async';
import 'dart:ffi';

import 'package:assistant/auto_gui/simulation.dart';
import 'package:assistant/auto_gui/system_control.dart';
import 'package:assistant/config/auto_tp_config.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';
import 'package:win32/win32.dart';

import '../win32/toast.dart';
import 'math_util.dart';

class KeyMouseUtil {
  static const int factor = 65535;

  static Future<void> moveR3D(List<int> distance, int step, int millis) async {
    List<int> prevDistance = [0, 0];
    for (int index = 1; index <= step; index++) {
      var pos =
          MathUtil.smoothStepWithPrev(distance, index / step, prevDistance);
      prevDistance = [prevDistance[0] + pos[0], prevDistance[1] + pos[1]];

      simulateMouseMove(pos[0], pos[1]);
      await Future.delayed(Duration(milliseconds: millis));
    }
  }

  static void simulateMouseMove(int dx, int dy) {
    final input = calloc<INPUT>();
    input.ref.type = INPUT_TYPE.INPUT_MOUSE;
    input.ref.mi.dx = dx;
    input.ref.mi.dy = dy;
    input.ref.mi.mouseData = 0;
    input.ref.mi.dwFlags = MOUSE_EVENT_FLAGS.MOUSEEVENTF_MOVE;
    input.ref.mi.time = 0;
    input.ref.mi.dwExtraInfo = 0;

    SendInput(1, input, sizeOf<INPUT>());
    free(input);
  }

  static Future<void> moveR3DWithoutStep(List<int> distance) async {
    await Simulation.sendInput.mouse.moveMouseBy(distance);
  }

  static Future<void> moveR(List<int> distance, int step, int millis) async {
    var initialPos = getCurLogicalPos();

    List<int> targetPos = [
      initialPos[0] + distance[0],
      initialPos[1] + distance[1]
    ];

    await move(targetPos, step, millis);
  }

  static void moveRWithoutStep(List<int> distance) {
    var initialPos = getCurLogicalPos();
    List<int> targetPos = [
      initialPos[0] + distance[0],
      initialPos[1] + distance[1]
    ];
    moveWithoutStep(targetPos);
  }

  static Future<void> move(List<int> point, int step, int millis) async {
    var initialPos = getCurLogicalPos();
    for (int index = 1; index <= step; index++) {
      var pos = MathUtil.smoothStep(initialPos, point, index / step);

      var res = physicalPos(pos);
      await Simulation.sendInput.mouse.move(res);
      await Future.delayed(Duration(milliseconds: millis));
    }
  }

  static Future<void> moveWithoutStep(List<int> point) async {
    var res = physicalPos(point);
    Simulation.sendInput.mouse.move(res);
  }

  static Future<void> click() async {
    Simulation.sendInput.mouse.leftButtonClick();
  }

  static Future<void> clickAtPoint(List<int> point, int delay) async {
    var res = physicalPos(point);
    Simulation.sendInput.mouse.move(res);
    await Future.delayed(Duration(milliseconds: 2));
    Simulation.sendInput.mouse.leftButtonClick();
    await Future.delayed(Duration(milliseconds: delay));
  }

  static Future<void> clickRight() async {
    Simulation.sendInput.mouse.rightButtonClick();
  }

  static List<int> getCurLogicalPos() {
    final currentRect = SystemControl.rect;
    final point = getMousePosOfWindow();
    return [
      ((point[0] - currentRect.left) * factor / (currentRect.width)).toInt(),
      ((point[1] - currentRect.top) * factor / (currentRect.height)).toInt()
    ];
  }

  static List<int> logicalDistance(List<int> distance) {
    final currentRect = SystemControl.rect;
    return [
      (distance[0] * factor / (currentRect.width - 1)).floor(),
      (distance[1] * factor / (currentRect.height - 1)).floor()
    ];
  }

  static List<int> physicalDistance(List<int> distance) {
    final currentRect = SystemControl.rect;
    return [
      (distance[0] * (currentRect.width - 1) / factor).ceil(),
      (distance[1] * (currentRect.height - 1) / factor).ceil()
    ];
  }

  static List<int> logicalPos(List<int> pPos) {
    final currentRect = SystemControl.rect;
    return [
      ((pPos[0] - currentRect.left) * factor / (currentRect.width - 1)).floor(),
      ((pPos[1] - currentRect.top) * factor / (currentRect.height - 1)).floor()
    ];
  }

  static List<int> physicalPos(List<int> lPos) {
    final currentRect = SystemControl.rect;
    return [
      currentRect.left + (lPos[0] * (currentRect.width - 1) / factor).ceil(),
      currentRect.top + (lPos[1] * (currentRect.height - 1) / factor).ceil()
    ];
  }

  static Future<void> send(String key) async {
    if (key == 'shiftleft' || key == 'shiftright' || key == 'shift') {
      await Simulation.sendInput.keyboard.keyDown(key);
      await Future.delayed(Duration(milliseconds: 20));
      await Simulation.sendInput.keyboard.keyUp(key);
      return;
    }
    await Simulation.sendInput.keyboard.keyPress(key);
  }

  static Future<void> sleep(int milliSeconds) async {
    await Future.delayed(Duration(milliseconds: milliSeconds));
  }

  static Future<void> wheel(int rowWheelNum) async {
    var config = AutoTpConfig.to;
    if (rowWheelNum > 0) {
      for (int i = 0; i < rowWheelNum; i++) {
        await Simulation.sendInput.mouse.verticalScroll(-1);
        if (config.getWheelIntervalDelay() > 0) {
          spinMillis(config.getWheelIntervalDelay());
        }
      }
    } else {
      for (int i = 0; i < -rowWheelNum; i++) {
        await Simulation.sendInput.mouse.verticalScroll(1);
        if (config.getWheelIntervalDelay() > 0) {
          spinMillis(config.getWheelIntervalDelay());
        }
      }
    }
  }

  static void spinMillis([int millis = 1]) {
    var stopwatch = Stopwatch();
    stopwatch.start();
    while (stopwatch.elapsedMilliseconds <= millis) {
      // 这里没有SpinWait的Dart等效实现，简单空循环
    }
    stopwatch.stop();
  }

  static Future<void> fastDrag(List<int> totalDrag, int shortMove) async {
    var config = AutoTpConfig.to;

    var dragSize = totalDrag.length;

    for (int index = 0; index < dragSize; index += 4) {
      List<int> drag = [
        totalDrag[index],
        totalDrag[index + 1],
        totalDrag[index + 2],
        totalDrag[index + 3]
      ];

      List<int> start = [drag[0], drag[1]];
      List<int> end = [drag[2], drag[3]];

      moveWithoutStep(start);
      await Future.delayed(
          Duration(milliseconds: config.getDragMoveStepDelay()));

      await Simulation.sendInput.mouse.leftButtonDown();
      await Future.delayed(
          Duration(milliseconds: config.getDragMoveStepDelay()));

      List<int> distance = [end[0] - start[0], end[1] - start[1]];
      if (distance[0] != 0) {
        moveRWithoutStep(
            logicalDistance(getShortMove([distance[0], 0], shortMove)));
        await Future.delayed(
            Duration(milliseconds: config.getDragMoveStepDelay()));
      } else if (distance[1] != 0) {
        moveRWithoutStep(
            logicalDistance(getShortMove([0, distance[1]], shortMove)));
        await Future.delayed(
            Duration(milliseconds: config.getDragMoveStepDelay()));
      }

      moveWithoutStep(end);
      await Future.delayed(
          Duration(milliseconds: config.getDragMoveStepDelay()));

      await Simulation.sendInput.mouse.leftButtonUp();
      await Future.delayed(
          Duration(milliseconds: config.getDragReleaseMouseDelay()));
    }
  }

  /// 获取短移动距离
  ///
  /// [moveDistance] 移动距离数组
  /// [shortMove] 短移动的步长
  /// 返回一个包含短移动距离的数组
  static List<int> getShortMove(List<int> moveDistance, int shortMove) {
    var longerIndex = (moveDistance[0].abs() > moveDistance[1].abs()) ? 0 : 1;
    var direction = (moveDistance[longerIndex] > 0) ? 1 : -1;
    return longerIndex == 0
        ? [shortMove * direction, 0]
        : [0, shortMove * direction];
  }

  /// 执行拖动操作
  ///
  /// [totalDrag] 总拖动距离数组
  static Future<void> drag(List<int> totalDrag) async {
    var config = AutoTpConfig.to;
    int pixelNum = config.getDragPixelNum();
    var dragSize = totalDrag.length;

    for (int index = 0; index < dragSize; index += 4) {
      List<int> drag = [
        totalDrag[index],
        totalDrag[index + 1],
        totalDrag[index + 2],
        totalDrag[index + 3]
      ];
      var start = physicalPos([drag[0], drag[1]]);
      var end = physicalPos([drag[2], drag[3]]);

      await Simulation.sendInput.mouse.move(start);
      await Future.delayed(
          Duration(milliseconds: config.getDragMoveStepDelay()));
      await mouseMoveMapX(((end[0] - start[0]) / pixelNum).toInt());
      await mouseMoveMapY(((end[1] - start[1]) / pixelNum).toInt());
    }
  }

  /// 在X轴上执行鼠标移动映射操作
  ///
  /// [dx] X轴上的移动距离
  static Future<void> mouseMoveMapX(int dx) async {
    var config = AutoTpConfig.to;
    var moveUnit = dx > 0 ? 20 : -20;
    await Simulation.sendInput.mouse.leftButtonDown();
    await Future.delayed(
        Duration(milliseconds: config.getDragReleaseMouseDelay()));
    var times = dx / moveUnit;

    for (var i = 0; i < times; i++) {
      await Simulation.sendInput.mouse.moveMouseBy([moveUnit, 0]);
      await Future.delayed(
          Duration(milliseconds: config.getDragMoveStepDelay()));
    }

    await Simulation.sendInput.mouse.leftButtonUp();
    await Simulation.sendInput.mouse.leftButtonDown();
    await Simulation.sendInput.mouse.leftButtonUp();
    await Future.delayed(
        Duration(milliseconds: config.getDragReleaseMouseDelay()));
  }

  /// 在Y轴上执行鼠标移动映射操作
  ///
  /// [dy] Y轴上的移动距离
  static Future<void> mouseMoveMapY(int dy) async {
    var config = AutoTpConfig.to;
    var moveUnit = dy > 0 ? 20 : -20;
    await Simulation.sendInput.mouse.leftButtonDown();
    await Future.delayed(Duration(milliseconds: config.getDragMoveStepDelay()));
    var times = dy / moveUnit;

    for (var i = 0; i < times; i++) {
      await Simulation.sendInput.mouse.moveMouseBy([0, moveUnit]);
      await Future.delayed(
          Duration(milliseconds: config.getDragReleaseMouseDelay()));
    }

    await Simulation.sendInput.mouse.leftButtonUp();
    await Simulation.sendInput.mouse.leftButtonDown();
    await Simulation.sendInput.mouse.leftButtonUp();
    await Future.delayed(Duration(milliseconds: config.getDragMoveStepDelay()));
  }

  /// 获取鼠标位置
  static List<int> getMousePosOfWindow() {
    final point = calloc<POINT>();
    GetCursorPos(point);
    int x = point.ref.x;
    int y = point.ref.y;
    free(point);

    if (x < SystemControl.rect.left || x > SystemControl.rect.right || y < SystemControl.rect.top || y > SystemControl.rect.bottom) {
      return [-1, -1];
    }
    return [x, y];
  }

  /// 显示鼠标坐标
  static void showCoordinate() {
    List<int> point = getMousePosOfWindow();
    if (point[0] == -1 || point[1] == -1) {
      return;
    }
    List<int> virtualPos = KeyMouseUtil.logicalPos(point);
    var text = '${virtualPos[0]}, ${virtualPos[1]}';
    Clipboard.setData(ClipboardData(text: text));
    showToast('已复制坐标: $text');
  }
}
