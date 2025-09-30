import 'dart:io';

import 'package:assistant/app/config/auto_tp_config.dart';
import 'package:assistant/helper/image/image_helper.dart';
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
import '../date_utils.dart';
import '../executor/route_executor.dart';
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

  // 找图（中心位置）
  jsRuntime.onMessage(findPic, findPicture);

  // 找图（左上角位置）
  jsRuntime.onMessage(findPicLT, (params) => findPicture(params, corner: lt));

  // 找图（右上角位置）
  jsRuntime.onMessage(findPicRT, (params) => findPicture(params, corner: rt));

  // 找图（右下角位置）
  jsRuntime.onMessage(findPicRB, (params) => findPicture(params, corner: rb));

  // 找图（左下角位置）
  jsRuntime.onMessage(findPicLB, (params) => findPicture(params, corner: lb));

  // 跳过下一个点位
  jsRuntime.onMessage(skipNext, skipNextPoint);

  // 跳转到指定点位
  jsRuntime.onMessage(toByName, toPointByName);

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

const lt = 1;
const rt = 2;
const rb = 3;
const lb = 4;

const largeHeight = 2000;

Future<List> findPictureWithMultiLocation(params, {int? corner}) async {
  final rect = params[0];
  final templateName = params[1];
  final threshold = params[2];
  var image = params[3];
  final bool mask = params[4];

  final picRecord = picRecordMap[templateName];
  if (picRecord == null || picRecord.mat == null) {
    return [-1, [], false];
  }

  var template = picRecord.mat!;
  final width = picRecord.width;
  final height = picRecord.height;
  final picSize = KeyMouseUtil.logicalDistance([width, height]);

  List<int> offset = [(picSize[0] / 2).toInt(), (picSize[1] / 2).toInt()];
  if (corner == lt) {
    offset = [0, 0];
  } else if (corner == rt) {
    offset = [picSize[0], 0];
  } else if (corner == rb) {
    offset = [picSize[0], picSize[1]];
  } else if (corner == lb) {
    offset = [0, picSize[1]];
  }

  if (picRecord.sourceHeight > largeHeight) {
    template = resize(template, 0.5);
    image = resize(image, 0.5);
  }

  var resultMat = mask
      ? cv.matchTemplate(
          image,
          template,
          cv.TM_CCOEFF_NORMED,
          mask: cv
              .threshold(
                template,
                0,
                255,
                cv.THRESH_BINARY,
              )
              .$2,
        )
      : cv.matchTemplate(image, template, cv.TM_CCOEFF_NORMED);

  if (picRecord.sourceHeight > largeHeight) {
    resultMat = resize(resultMat, 2);
  }

  final thresholdMat =
      cv.threshold(resultMat, threshold, 1.0, cv.THRESH_BINARY);

  // 获取所有匹配位置
  final locations = cv.findNonZero(thresholdMat.$2);

  List<List<int>> results = [];

  // 收集所有匹配结果
  for (var i = 0; i < locations.rows; i++) {
    final byteList = locations.row(i).data;
    // 解析前4个字节为x坐标（小端序）
    final x =
        byteList[0] | byteList[1] << 8 | byteList[2] << 16 | byteList[3] << 24;
    // 解析后4个字节为y坐标（小端序）
    final y =
        byteList[4] | byteList[5] << 8 | byteList[6] << 16 | byteList[7] << 24;

    final logicPos = KeyMouseUtil.logicalDistance([x, y]);

    results.add(
        [rect[0] + logicPos[0] + offset[0], rect[1] + logicPos[1] + offset[1]]);
  }

  return results;
}

findPicture(params, {int? corner}) async {
  final leftTop = KeyMouseUtil.physicalPos([params[0][0], params[0][1]]);
  final rightBottom = KeyMouseUtil.physicalPos([params[0][2], params[0][3]]);
  final image = captureImageWindows(
      ScreenRect(leftTop[0], leftTop[1], rightBottom[0], rightBottom[1]));
  final picRecord = picRecordMap[params[1]];
  if (picRecord == null || picRecord.mat == null) {
    return [-1, [], false];
  }

  final template = picRecord.mat!;
  final width = picRecord.width;
  final height = picRecord.height;
  final picSize = KeyMouseUtil.logicalDistance([width, height]);
  final matchThreshold = AutoTpConfig.to.getMatchThreshold();

  List<int> offset = [(picSize[0] / 2).toInt(), (picSize[1] / 2).toInt()];
  if (corner == lt) {
    offset = [0, 0];
  } else if (corner == rt) {
    offset = [picSize[0], 0];
  } else if (corner == rb) {
    offset = [picSize[0], picSize[1]];
  } else if (corner == lb) {
    offset = [0, picSize[1]];
  }

  if (params.length == 2) {
    final result = cv.matchTemplate(image, template, cv.TM_CCOEFF_NORMED);
    final minMaxLoc = cv.minMaxLoc(result);
    final logicDistance =
        KeyMouseUtil.logicalDistance([minMaxLoc.$4.x, minMaxLoc.$4.y]);

    return [
      minMaxLoc.$2,
      [
        params[0][0] + logicDistance[0] + offset[0],
        params[0][1] + logicDistance[1] + offset[1],
      ],
      minMaxLoc.$2 > matchThreshold,
    ];
  } else if (params.length == 4) {
    final int interval = params[2];
    final int totalDuration = params[3];

    assert(interval > 0);
    assert(totalDuration > 0);

    late List<dynamic> res;

    final int startTime = currentMillis();
    while (currentMillis() - startTime < totalDuration) {
      final result = cv.matchTemplate(image, template, cv.TM_CCOEFF_NORMED);
      final minMaxLoc = cv.minMaxLoc(result);
      final logicDistance =
          KeyMouseUtil.logicalDistance([minMaxLoc.$4.x, minMaxLoc.$4.y]);
      res = [
        minMaxLoc.$2,
        [
          params[0][0] + logicDistance[0] + offset[0],
          params[0][1] + logicDistance[1] + offset[1],
        ],
        minMaxLoc.$2 > matchThreshold,
      ];

      if (minMaxLoc.$2 > matchThreshold) {
        return res;
      }

      await Future.delayed(Duration(milliseconds: interval));
    }

    return res;
  }
}

findPointColor(params) async {
  if (params.length == 2) {
    final res = await FindUtil.findColor(
        convertDynamicListToIntList(params[0]), params[1]);
    return res;
  } else if (params.length == 4) {
    final int interval = params[2];
    final int totalDuration = params[3];

    assert(interval > 0);
    assert(totalDuration > 0);

    late bool res;

    final int startTime = currentMillis();
    while (currentMillis() - startTime < totalDuration) {
      res = await FindUtil.findColor(
          convertDynamicListToIntList(params[0]), params[1]);
      if (res) {
        return res;
      }

      await Future.delayed(Duration(milliseconds: interval));
    }

    return res;
  }
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
  await showToast(params['message'], duration: params['duration']);
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

/// 跳过下一个点位
skipNextPoint(params) async {
  RouteExecutor.toNext();
}

/// 跳转到指定点位
toPointByName(params) async {
  RouteExecutor.toByName(params[0]);
}
