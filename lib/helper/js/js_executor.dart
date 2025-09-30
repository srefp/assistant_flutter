import 'dart:io';

import 'package:assistant/app/config/auto_tp_config.dart';
import 'package:assistant/helper/helper.dart';
import 'package:assistant/helper/script_parser.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_js/flutter_js.dart';

import '../../app/config/script_config.dart';
import '../../component/dialog.dart';
import '../../component/text/win_text.dart';
import 'convenience_register.dart';
import 'data_processing_register.dart';
import 'helper_register.dart';
import 'keyboard_register.dart';
import 'mouse_async_register.dart';
import 'mouse_register.dart';

const tp = "tp";
const tip = "tip";
const wait = "wait";
const findMousePos = "findMousePos";
const move = "move";
const moveAsync = "moveAsync";
const moveR = "moveR";
const moveRAsync = "moveRAsync";
const moveR3D = "moveR3D";
const moveR3DAsync = "moveR3DAsync";
const drag = "drag";
const dragAsync = "dragAsync";
const mDown = "mDown";
const mDownAsync = "mDownAsync";
const mUp = "mUp";
const mUpAsync = "mUpAsync";
const click = "click";
const clickAsync = "clickAsync";
const kDown = "kDown";
const kUp = "kUp";
const press = "press";
const cp = "cp";
const wheel = "wheel";
const wheelAsync = "wheelAsync";
const map = "map";
const book = "book";
const tpc = "tpc";
const tpcPlus = "tpcPlus";
const findColor = "findColor";
const findPic = "findPic";
const findPicLT = "findPicLT";
const findPicRT = "findPicRT";
const findPicRB = "findPicRB";
const findPicLB = "findPicLB";
const skipNext = "skipNext";
const toByName = "toByName";
const sh = "sh";
const maxCurrentWindow = "maxCurrentWindow";
const moveToCenter = "moveToCenter";
const getInfo = "getInfo";
const executeSql = "executeSql";

const hintKeys = [
  tp,
  tpc,
  tpcPlus,
  wait,
  click,
  findMousePos,
  move,
  moveR,
  moveR3D,
  mDown,
  mUp,
  drag,
  wheel,
  clickAsync,
  moveAsync,
  moveRAsync,
  moveR3DAsync,
  mDownAsync,
  mUpAsync,
  dragAsync,
  wheelAsync,
  kDown,
  kUp,
  press,
  cp,
  map,
  book,
  findColor,
  findPic,
  findPicLT,
  findPicRT,
  findPicRB,
  findPicLB,
  tip,
  sh,
  skipNext,
  toByName,
  maxCurrentWindow,
  moveToCenter,
];

const keys = [
  tp,
  tpc,
  tpcPlus,
  findMousePos,
  wait,
  click,
  move,
  moveR,
  moveR3D,
  mDown,
  mUp,
  drag,
  wheel,
  clickAsync,
  moveAsync,
  moveRAsync,
  moveR3DAsync,
  mDownAsync,
  mUpAsync,
  dragAsync,
  wheelAsync,
  kDown,
  kUp,
  press,
  cp,
  map,
  book,
  findPic,
  findPicLT,
  findPicRT,
  findPicRB,
  findPicLB,
  moveToCenter,

  // 数据处理
  getInfo,
  executeSql,
];

JavascriptRuntime jsRuntime = getJavascriptRuntime(xhr: false);

late String jsFunction;

bool crusade = false;

void registerJsFunc() async {
  jsFunction = await rootBundle.loadString('assets/js/func.js');
  jsFunction = zipJsCode(jsFunction);

  // 注册所有函数
  jsRuntime.evaluate(jsFunction);

  // 注册预定义变量
  jsRuntime.evaluate(ScriptConfig.to.getVariable());

  // 注册鼠标函数
  registerMouseFunc();

  // 注册异步鼠标函数
  registerMouseAsyncFunc();

  // 注册键盘函数
  registerKeyboardFunc();

  // 注册便捷函数
  registerConvenience();

  // 注册帮助类函数
  registerHelper();

  // 注册数据库函数
  registerDataProcessing();
}

final Set<String> importedLib = {};

final libRegex = '// *import lib (.*)';

/// 运行js代码
Future<void> runScript(
  String code, {
  bool addAwait = true,
  bool stoppable = false,
  bool libEnabled = false,
}) async {
  if (libEnabled) {
    code = await loadLib(code);
    importedLib.clear();
  }

  // 将code中的异步函数添加await
  if (addAwait) {
    for (final key in keys) {
      if (!stoppable || key.startsWith('find')) {
        code = code.replaceAll('$key(', 'await $key(');
      } else {
        code = code.replaceAll('$key(',
            'if (!scriptRunning) {scriptRunning = true; return;} await $key(');
      }
    }
  }

  // 记录是否开启识图半自动
  final enabledWorldDetect = AutoTpConfig.to.isWorldDetectEnabled();
  final enabledTpDetect = AutoTpConfig.to.isTpDetectEnabled();
  final enabledMultiTpDetect = AutoTpConfig.to.isMultiTpDetectEnabled();

  if (AutoTpConfig.to.isCloseDetectWhenJs()) {
    // 禁止识图半自动
    appLog.info('运行脚本时关闭了识图半自动');
    AutoTpConfig.to.save(AutoTpConfig.keyWorldDetectEnabled, false);
    AutoTpConfig.to.save(AutoTpConfig.keyTpDetectEnabled, false);
    AutoTpConfig.to.save(AutoTpConfig.keyMultiTpDetectEnabled, false);
  }

  try {
    JsEvalResult result = await jsRuntime.evaluateAsync(
        '${stoppable ? 'scriptRunning = true;' : ''}(async function() { $code })();');
    jsRuntime.executePendingJob();
    await jsRuntime.handlePromise(result);
  } catch (e) {
    dialog(
        title: '脚本执行出错，建议重启，否则会内存溢出',
        child: SizedBox(
          height: 120,
          child: ListView(
            children: [
              WinText(e.toString()),
            ],
          ),
        ));
  } finally {
    await Future.delayed(const Duration(seconds: 2));

    // 恢复是否开启识图半自动
    appLog.info('恢复了识图半自动');
    AutoTpConfig.to
        .save(AutoTpConfig.keyWorldDetectEnabled, enabledWorldDetect);
    AutoTpConfig.to.save(AutoTpConfig.keyTpDetectEnabled, enabledTpDetect);
    AutoTpConfig.to
        .save(AutoTpConfig.keyMultiTpDetectEnabled, enabledMultiTpDetect);
  }
}

loadLib(String code) async {
  final libs = RegExp(libRegex).allMatches(code);
  for (final lib in libs) {
    final libFile = lib.group(1)!;
    List<String> filteredLines = [];
    if (!importedLib.contains(libFile)) {
      importedLib.add(libFile);
      List<String> lines = File(libFile).readAsLinesSync();
      for (var line in lines) {
        if (line.startsWith('import')) {
          continue;
        }
        if (line.startsWith('export')) {
          line = line.replaceFirst('export', '');
        }
        filteredLines.add(line);
      }
    }
    code = filteredLines.join('\n') + code;
  }
  return code;
}
