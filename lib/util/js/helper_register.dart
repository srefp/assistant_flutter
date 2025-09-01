import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:opencv_dart/opencv.dart' as cv;
import 'package:win32/win32.dart';

import '../../app/windows_app.dart';
import '../../auto_gui/key_mouse_util.dart';
import '../../auto_gui/keyboard.dart';
import '../../auto_gui/operations.dart' show factor;
import '../../auto_gui/system_control.dart';
import '../../components/dialog.dart';
import '../../components/win_text.dart';
import '../../cv/cv.dart';
import '../../db/pic_record_db.dart';
import '../../win32/toast.dart';
import '../data_converter.dart';
import '../find_util.dart';
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
  final left = params[0][0];
  final top = params[0][1];
  final right = params[0][2];
  final bottom = params[0][3];
  final image = captureImageWindows(ScreenRect(left, top, right, bottom));
  print('image: $image');
  final template = picRecordMap[params[1]]?.mat;
  print('template: $template');
  if (template == null) {
    return {'match': -1, 'loc': cv.Point(0, 0)};
  }
  final result = cv.matchTemplate(image, template, cv.TM_CCOEFF_NORMED);
  final minMaxLoc = cv.minMaxLoc(result);
  print('找图结果：${minMaxLoc.$1}');
  return {'match': minMaxLoc.$1, 'loc': minMaxLoc.$3};
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
