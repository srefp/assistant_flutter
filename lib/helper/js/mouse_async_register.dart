import 'package:flutter_auto_gui/flutter_auto_gui.dart';

import '../auto_gui/key_mouse_util.dart';
import '../auto_gui/operations.dart' hide move, click;
import '../auto_gui/system_control.dart';
import '../data_converter.dart';
import 'js_executor.dart';

void registerMouseAsyncFunc() {
  // 鼠标移动
  jsRuntime.onMessage(moveAsync, moveMouseAsync);

  // 鼠标相对移动
  jsRuntime.onMessage(moveRAsync, moveRelativeAsync);

  // 3D视角的鼠标相对移动
  jsRuntime.onMessage(moveR3DAsync, moveRelative3DAsync);

  // 滚轮
  jsRuntime.onMessage(wheelAsync, mouseWheelAsync);

  // 鼠标按下
  jsRuntime.onMessage(mDownAsync, mouseDownAsync);

  // 鼠标抬起
  jsRuntime.onMessage(mUpAsync, mouseUpAsync);

  // 点击
  jsRuntime.onMessage(clickAsync, mouseClickAsync);

  // 拖动
  jsRuntime.onMessage(dragAsync, mouseDragAsync);
}

mouseDragAsync(params) async {
  SystemControl.refreshRect();
  KeyMouseUtil.fastDrag(
      convertDynamicListToIntList(params['coords']), params['shortMove']);
  await Future.delayed(Duration(milliseconds: params['delay']));
}

mouseClickAsync(params) async {
  SystemControl.refreshRect();

  // 最少参数：click(10)
  if (params.length == 1) {
    api.click();
    await Future.delayed(Duration(milliseconds: params[0]));
    return;
  }

  // 最多参数：click('left', [12345, 12345], 4, 5, 20)
  if (params.length == 5) {
    KeyMouseUtil.move(convertDynamicListToIntList(params[1]), 1, 0);
    await Future.delayed(Duration(milliseconds: 2));
    api.click(
      button: {
        'left': MouseButton.left,
        'right': MouseButton.right,
        'middle': MouseButton.middle,
      }[params[0]]!,
      clicks: params[2],
      interval: Duration(milliseconds: params[3]),
    );
    await Future.delayed(Duration(milliseconds: params[4]));
    return;
  }

  // 三选一：坐标
  if (params.length == 2 && params[0] is List && params[1] is int) {
    KeyMouseUtil.clickAtPoint(
        convertDynamicListToIntList(params[0]), 0);
    await Future.delayed(Duration(milliseconds: params[1]));
  }
  // 三选二：坐标+次数
  else if (params.length == 4 &&
      params[0] is List &&
      params[1] is int &&
      params[2] is int &&
      params[3] is int) {
    KeyMouseUtil.move(convertDynamicListToIntList(params[0]), 1, 0);
    await Future.delayed(Duration(milliseconds: 1));
    api.click(
      clicks: params[1],
      interval: Duration(milliseconds: params[2]),
    );
    await Future.delayed(Duration(milliseconds: params[3]));
  }

  // 三选一：键位
  else if (params[0] is String && params[1] is int) {
    api.click(
      button: {
        'left': MouseButton.left,
        'right': MouseButton.right,
        'middle': MouseButton.middle,
      }[params[0]]!,
    );
    await Future.delayed(Duration(milliseconds: params[1]));
  }
  // 三选一：次数
  else if (params[0] is int && params[1] is int && params[2] is int) {
    api.click(
      clicks: params[0],
      interval: Duration(milliseconds: params[1]),
    );
    await Future.delayed(Duration(milliseconds: params[2]));
  }

  // 三选二：键位+坐标
  else if (params[0] is String && params[1] is List && params[2] is int) {
    KeyMouseUtil.move(convertDynamicListToIntList(params[1]), 1, 0);
    api.click(
      button: {
        'left': MouseButton.left,
        'right': MouseButton.right,
        'middle': MouseButton.middle,
      }[params[0]]!,
    );
    await Future.delayed(Duration(milliseconds: params[2]));
  }
  // 三选二：键位+次数
  else if (params[0] is String &&
      params[1] is int &&
      params[2] is int &&
      params[3] is int) {
    api.click(
      button: {
        'left': MouseButton.left,
        'right': MouseButton.right,
        'middle': MouseButton.middle,
      }[params[0]]!,
      clicks: params[1],
      interval: Duration(milliseconds: params[2]),
    );
    await Future.delayed(Duration(milliseconds: params[3]));
  }
}

mouseUpAsync(params) async {
  if (params.length == 1) {
    api.mouseUp();
    await Future.delayed(Duration(milliseconds: params[0]));
  } else if (params.length == 2) {
    api.mouseUp(
        button: {
      'left': MouseButton.left,
      'right': MouseButton.right,
      'middle': MouseButton.middle,
    }[params[0]]!);
    await Future.delayed(Duration(milliseconds: params[1]));
  }
}

mouseDownAsync(params) async {
  if (params.length == 1) {
    api.mouseDown();
    await Future.delayed(Duration(milliseconds: params[0]));
  } else if (params.length == 2) {
    api.mouseDown(
        button: {
      'left': MouseButton.left,
      'right': MouseButton.right,
      'middle': MouseButton.middle,
    }[params[0]]!);
    await Future.delayed(Duration(milliseconds: params[1]));
  }
}

mouseWheelAsync(params) async {
  api.scroll(clicks: -params['clicks']);
  await Future.delayed(Duration(milliseconds: params['delay']));
}

moveRelative3DAsync(params) async {
  List<int> distance = convertDynamicListToIntList(params[0]);
  if (params.length == 2) {
    KeyMouseUtil.moveR3D(distance, 1, 0);
    await Future.delayed(Duration(milliseconds: params[1]));
  } else if (params.length == 4) {
    KeyMouseUtil.moveR3D(distance, params[1], params[2]);
    await Future.delayed(Duration(milliseconds: params[3]));
  }
}

moveRelativeAsync(params) async {
  List<int> distance = convertDynamicListToIntList(params[0]);
  if (params.length == 2) {
    KeyMouseUtil.moveR(distance, 1, 0);
    await Future.delayed(Duration(milliseconds: params[1]));
  } else if (params.length == 4) {
    KeyMouseUtil.moveR(distance, params[1], params[2]);
    await Future.delayed(Duration(milliseconds: params[3]));
  }
}

moveMouseAsync(params) async {
  List<int> distance = convertDynamicListToIntList(params[0]);
  if (params.length == 2) {
    KeyMouseUtil.move(distance, 1, 0);
    await Future.delayed(Duration(milliseconds: params[1]));
  } else if (params.length == 4) {
    KeyMouseUtil.move(distance, params[1], params[2]);
    await Future.delayed(Duration(milliseconds: params[3]));
  }
}
