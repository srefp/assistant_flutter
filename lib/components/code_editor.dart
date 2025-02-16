import 'dart:math';

import 'package:assistant/components/win_text.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/darcula.dart';
import 'package:highlight/languages/javascript.dart';

const text = '''const material = '鸟蛋';
const byeByeList = ['非常感谢！祝你抽卡不歪，十连双金！'];

// 打招呼
press('return', 100);
press('return', 20);
cp(helloList[randInt(0, helloList.length)], 200);
press('return', 300);


// 切换第一个角色
press('1', 300);

// 动两下
click([50717, 34270], 100);
click([50717, 34270], 100);

// 扫码
kDown('e', 200);
moveR3D([3000, 500], 120);
kUp('e', 120);

wait(1000);

// 通过狼王传送右边的锚点，第二个参数表示不记住此锚点（记不记住感觉差别不大）
tp({ boss: 'lw', pos: [39194, 24769] }, false, 3500);

// 插值转向
moveR3D([100, 0], 10, 10, 200);

// 跑
kDown('w', 50);
click('right', 300);
kUp('w', 50);
wait(600);

// 走
kDown('w', 800);
kUp('w', 60);

// 等
wait(600);


// 插值扫码（就是可以控制扫码过程中转向的快慢，后面参数是分多少次，每次的后摇是多少ms，然后最后等待多长时间）
moveR3D([-300, 0], 20, 30, 120);
kDown('e', 200);
moveR3D([900, -100], 20, 30, 120);
kUp('e', 120);


press('return', 100);
press('return', 20);

// 感谢
cp(byeByeList[randInt(0, byeByeList.length)], 200);
press('return', 120);
  ''';

final controller = CodeController(
  text: text, // Initial code
  language: javascript,
);

/// 代码编辑器
class CodeEditor extends StatefulWidget {
  const CodeEditor({super.key});

  @override
  State<CodeEditor> createState() => _CodeEditorState();
}

class _CodeEditorState extends State<CodeEditor> {
  final ScrollController _hCtrl = ScrollController();
  final ScrollController _vCtrl = ScrollController();

  @override
  Widget build(BuildContext context) {
    return CodeTheme(
      data: CodeThemeData(
        styles: darculaTheme,
      ),
      child: Scrollbar(
        thumbVisibility: true,
        notificationPredicate: (ScrollNotification notification) => notification.depth == 1,
        key: const Key("scriptEditorVerticalScrollbarKey"),
        controller: _vCtrl,
        child: SingleChildScrollView(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double boxHeight = 2500;
              final double boxWidth = calculateText(text);
              return Scrollbar(
                key: const Key("scriptEditorHorizontalScrollbarKey"),
                thumbVisibility: true,
                controller: _hCtrl,
                child: SingleChildScrollView(
                  controller: _hCtrl,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    height: constraints.maxHeight,
                    width: max(boxWidth, constraints.maxWidth),
                    child: SingleChildScrollView(
                      controller: _vCtrl,
                      child: SizedBox(
                        height: boxHeight,
                        child: CodeField(
                          textStyle: TextStyle(fontSize: 16, fontFamily: fontFamily),
                          controller: controller,
                          minLines: 36,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
          ),
        ),
      ),
    );
  }

  double calculateText(String text) {
    final textPainter = TextPainter(
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
      text: TextSpan(text: text, style: TextStyle(fontSize: 16, fontFamily: fontFamily)),
    );
    textPainter.layout();

    return textPainter.width;
  }
}
