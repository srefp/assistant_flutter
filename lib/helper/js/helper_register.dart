import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:opencv_dart/opencv.dart' as cv;
import 'package:win32/win32.dart';

import '../../app/dao/pic_record_db.dart';
import '../../app/windows_app.dart';
import '../../component/dialog.dart';
import '../../component/text/win_text.dart';
import '../auto_gui/key_mouse_util.dart';
import '../auto_gui/operations.dart';
import '../auto_gui/system_control.dart';
import '../cv/cv.dart';
import '../data_converter.dart';
import '../find_util.dart';
import '../win32/toast.dart';
import 'js_executor.dart';

void registerHelper() {
  // 打印日志
  jsRuntime.onMessage('log', echoLog);

  // 移动到中心
  jsRuntime.onMessage(moveToCenter, moveTargetToCenter);

  // 弹出消息框
  jsRuntime.onMessage(tip, showTip);

  // 复制粘贴
  jsRuntime.onMessage(cp, copyAndPaste);

  // 找色
  jsRuntime.onMessage(findColor, findPointColor);

  // 找图
  jsRuntime.onMessage(findPic, findPicture);

  // 执行shell脚本
  jsRuntime.onMessage(sh, executeShell);

  // 当前窗口最大化
  jsRuntime.onMessage(maxCurrentWindow, maximizeCurrentWindow);
}

maximizeCurrentWindow(params) async {
  // 获取当前前台窗口句柄
  final hWnd = GetForegroundWindow();
  if (hWnd == 0) return; // 无前台窗口时返回

  // 调用Win32 API最大化窗口（SW_MAXIMIZE=3）
  ShowWindow(hWnd, SHOW_WINDOW_CMD.SW_MAXIMIZE);
}

executeShell(parameters) async {
  final params = <String>[];
  for (var i = 0; i < parameters.length; i++) {
    params.add(parameters[i].toString());
  }
  Process? process;
  try {
    process = await Process.start(
      params[0],
      params.sublist(1),
      mode: ProcessStartMode.detached,
      environment: Platform.environment,
    );
  } catch (e) {
    dialog(
      title: '错误',
      child: SizedBox(
        height: 200,
        child: ListView(
          children: [
            WinText(e.toString()),
          ],
        ),
      ),
    );
  }
  return process?.pid;
}

findPicture(params) async {
  final leftTop = KeyMouseUtil.physicalPos([params[0][0], params[0][1]]);
  final rightBottom = KeyMouseUtil.physicalPos([params[0][2], params[0][3]]);
  final image = captureImageWindows(
      ScreenRect(leftTop[0], leftTop[1], rightBottom[0], rightBottom[1]));
  final template = picRecordMap[params[1]]?.mat;
  if (template == null) {
    return {'match': -1, 'loc': cv.Point(0, 0)};
  }

  if (params.length == 2) {
    final result = cv.matchTemplate(image, template, cv.TM_CCOEFF_NORMED);
    final minMaxLoc = cv.minMaxLoc(result);
    final logicDistance =
        KeyMouseUtil.logicalDistance([minMaxLoc.$4.x, minMaxLoc.$4.y]);
    return {
      'match': minMaxLoc.$2,
      'loc': [params[0][0] + logicDistance[0], params[0][1] + logicDistance[1]],
      'find': minMaxLoc.$2 > 0.9,
    };
  } else if (params.length == 4) {
    final int interval = params[2];
    final int totalDuration = params[3];

    assert(interval > 0);
    assert(totalDuration > 0);

    // 每隔一段间隔时间找一次，指定时长内返回
    int currentDuration = 0;

    late Map<String, dynamic> res;

    while (currentDuration < totalDuration) {
      final result = cv.matchTemplate(image, template, cv.TM_CCOEFF_NORMED);
      final minMaxLoc = cv.minMaxLoc(result);
      final logicDistance =
          KeyMouseUtil.logicalDistance([minMaxLoc.$4.x, minMaxLoc.$4.y]);
      res = {
        'match': minMaxLoc.$2,
        'loc': [
          params[0][0] + logicDistance[0],
          params[0][1] + logicDistance[1]
        ],
        'find': minMaxLoc.$2 > 0.9,
      };

      if (minMaxLoc.$2 > 0.9) {
        return res;
      }

      currentDuration += interval;
      await Future.delayed(Duration(milliseconds: interval));
    }

    return res;
  }
}

findPointColor(params) async {
  final res = await FindUtil.findColor(
      convertDynamicListToIntList(params[0]), params[1]);
  return res;
}

copyAndPaste(params) async {
  await Clipboard.setData(ClipboardData(text: params['text']));
  await api.keyDown(key: 'ctrl');
  await api.keyDown(key: 'v');
  await api.keyUp(key: 'v');
  await api.keyUp(key: 'ctrl');
}

showTip(params) async {
  if (params['duration'] == null) {
    params['duration'] = 3000;
  }
  showToast(params['message'], duration: params['duration']);
}

echoLog(params) {
  WindowsApp.logModel.info(params['info']);
}

Future<void> moveTargetToCenter(params) async {
  // 获取鼠标当前位置
  final pos = KeyMouseUtil.getCurLogicalPos();
  final List<int> center = [factor ~/ 2, factor ~/ 2];
  final List<int> totalDrag = [
    pos[0],
    pos[1] - 3000,
    center[0],
    center[1] - 3000
  ];
  await KeyMouseUtil.fastDrag(totalDrag, 20);
}
