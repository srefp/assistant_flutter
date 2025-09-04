import 'package:assistant/helper/script_parser.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_js/flutter_js.dart';

import '../../component/dialog.dart';
import '../../component/text/win_text.dart';
import 'convenience_register.dart';
import 'helper_register.dart';
import 'keyboard_register.dart';
import 'mouse_register.dart';

const tp = "tp";
const tip = "tip";
const wait = "wait";
const move = "move";
const moveR = "moveR";
const moveR3D = "moveR3D";
const drag = "drag";
const mDown = "mDown";
const mUp = "mUp";
const click = "click";
const kDown = "kDown";
const kUp = "kUp";
const press = "press";
const cp = "cp";
const wheel = "wheel";
const map = "map";
const book = "book";
const tpc = "tpc";
const findColor = "findColor";
const findPic = "findPic";
const findPicLT = "findPicLT";
const findPicRT = "findPicRT";
const findPicRB = "findPicRB";
const findPicLB = "findPicLB";
const sh = "sh";
const maxCurrentWindow = "maxCurrentWindow";
const moveToCenter = "moveToCenter";

const hintKeys = [
  tp,
  wait,
  move,
  moveR,
  moveR3D,
  drag,
  mDown,
  mUp,
  click,
  kDown,
  kUp,
  press,
  cp,
  wheel,
  map,
  book,
  tpc,
  findColor,
  findPic,
  findPicLT,
  findPicRT,
  findPicRB,
  findPicLB,
  tip,
  sh,
  maxCurrentWindow,
  moveToCenter,
];

const keys = [
  tp,
  wait,
  move,
  moveR,
  moveR3D,
  drag,
  mDown,
  mUp,
  click,
  kDown,
  kUp,
  press,
  cp,
  wheel,
  map,
  book,
  tpc,
  findPic,
  findPicLT,
  findPicRT,
  findPicRB,
  findPicLB,
  moveToCenter,
];

JavascriptRuntime jsRuntime = getJavascriptRuntime(xhr: false);

late String jsFunction;

bool crusade = false;

void registerJsFunc() async {
  jsFunction = await rootBundle.loadString('assets/js/func.js');
  jsFunction = zipJsCode(jsFunction);

  // 注册所有函数
  jsRuntime.evaluate(jsFunction);

  // 注册鼠标函数
  registerMouseFunc();

  // 注册键盘函数
  registerKeyboardFunc();

  // 注册便捷函数
  registerConvenience();

  // 注册帮助类函数
  registerHelper();
}

/// 运行js代码
Future<void> runScript(
  String code, {
  bool addAwait = true,
  bool stoppable = false,
}) async {
  // 将code中的异步函数添加await
  if (addAwait) {
    for (final key in keys) {
      if (stoppable) {
        code = code.replaceAll('$key(',
            'if (!scriptRunning) { scriptRunning = true; return;} await $key(');
      } else {
        code = code.replaceAll('$key(', 'await $key(');
      }
    }
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
  }
}
