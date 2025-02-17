import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show InkWell;
import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/languages/dart.dart';
import 'package:re_highlight/languages/javascript.dart';

import 'find.dart';
import 'menu.dart';

const List<CodePrompt> _kStringPrompts = [
  CodeFieldPrompt(
      word: 'length',
      type: 'int'
  ),
  CodeFieldPrompt(
      word: 'isEmpty',
      type: 'bool'
  ),
  CodeFieldPrompt(
      word: 'isNotEmpty',
      type: 'bool'
  ),
  CodeFieldPrompt(
      word: 'characters',
      type: 'Characters'
  ),
  CodeFieldPrompt(
      word: 'hashCode',
      type: 'int'
  ),
  CodeFieldPrompt(
      word: 'codeUnits',
      type: 'List<int>'
  ),
  CodeFieldPrompt(
      word: 'runes',
      type: 'Runes'
  ),
  CodeFunctionPrompt(
      word: 'codeUnitAt',
      type: 'int',
      parameters: {
        'index': 'int'
      }
  ),
  CodeFunctionPrompt(
      word: 'replaceAll',
      type: 'String',
      parameters: {
        'from': 'Pattern',
        'replace': 'String',
      }
  ),
  CodeFunctionPrompt(
      word: 'contains',
      type: 'bool',
      parameters: {
        'other': 'String',
      }
  ),
  CodeFunctionPrompt(
      word: 'split',
      type: 'List<String>',
      parameters: {
        'pattern': 'Pattern',
      }
  ),
  CodeFunctionPrompt(
      word: 'endsWith',
      type: 'bool',
      parameters: {
        'other': 'String',
      }
  ),
  CodeFunctionPrompt(
      word: 'startsWith',
      type: 'bool',
      parameters: {
        'other': 'String',
      }
  )
];

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

/// 代码编辑器
class Editor extends StatefulWidget {
  const Editor({super.key});

  @override
  State<Editor> createState() => _EditorState();
}

class _EditorState extends State<Editor> {

  final CodeLineEditingController _controller = CodeLineEditingController();

  @override
  void initState() {
    _controller.text = text;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CodeAutocomplete(
      viewBuilder: (context, notifier, onSelected) {
        return _DefaultCodeAutocompleteListView(
          notifier: notifier,
          onSelected: onSelected,
        );
      },
      promptsBuilder: DefaultCodeAutocompletePromptsBuilder(
        language: langDart,
        directPrompts: const [
          CodeFieldPrompt(
              word: 'foo',
              type: 'String'
          ),
          CodeFieldPrompt(
              word: 'bar',
              type: 'String'
          ),
          CodeFunctionPrompt(
              word: 'hello',
              type: 'void',
              parameters: {
                'value': 'String',
              }
          )
        ],
        relatedPrompts: {
          'foo': _kStringPrompts,
          'bar': _kStringPrompts,
        },
      ),
      child: CodeEditor(
        style: CodeEditorStyle(
          fontFamily: 'Consolas',
          fontSize: 16,
          textColor: const Color(0xffbcbec4),
          codeTheme: CodeHighlightTheme(
            languages: {
              'javascript': CodeHighlightThemeMode(
                  mode: langJavascript
              )
            },
            theme: {
              'root':
              TextStyle(backgroundColor: Color(0xff2b2b2b), color: Color(0xffbababa)),
              'strong': TextStyle(color: Color(0xffa8a8a2)),
              'emphasis': TextStyle(color: Color(0xffa8a8a2), fontStyle: FontStyle.italic),
              'bullet': TextStyle(color: Color(0xff6896ba)),
              'quote': TextStyle(color: Color(0xff6896ba)),
              'link': TextStyle(color: Color(0xff6896ba)),
              'number': TextStyle(color: Color(0xff6896ba)),
              'regexp': TextStyle(color: Color(0xff6896ba)),
              'literal': TextStyle(color: Color(0xff6896ba)),
              'code': TextStyle(color: Color(0xffa6e22e)),
              'selector-class': TextStyle(color: Color(0xffa6e22e)),
              'keyword': TextStyle(color: Color(0xffcb7832)),
              'selector-tag': TextStyle(color: Color(0xffcb7832)),
              'section': TextStyle(color: Color(0xffcb7832)),
              'attribute': TextStyle(color: Color(0xffcb7832)),
              'name': TextStyle(color: Color(0xffcb7832)),
              'variable': TextStyle(color: Color(0xffcb7832)),
              'params': TextStyle(color: Color(0xffb9b9b9)),
              'string': TextStyle(color: Color(0xff6a8759)),
              'subst': TextStyle(color: Color(0xffe0c46c)),
              'type': TextStyle(color: Color(0xffe0c46c)),
              'built_in': TextStyle(color: Color(0xffe0c46c)),
              'builtin-name': TextStyle(color: Color(0xffe0c46c)),
              'symbol': TextStyle(color: Color(0xffe0c46c)),
              'selector-id': TextStyle(color: Color(0xffe0c46c)),
              'selector-attr': TextStyle(color: Color(0xffe0c46c)),
              'selector-pseudo': TextStyle(color: Color(0xffe0c46c)),
              'template-tag': TextStyle(color: Color(0xffe0c46c)),
              'template-variable': TextStyle(color: Color(0xffe0c46c)),
              'addition': TextStyle(color: Color(0xffe0c46c)),
              'comment': TextStyle(color: Color(0xff7f7f7f)),
              'deletion': TextStyle(color: Color(0xff7f7f7f)),
              'meta': TextStyle(color: Color(0xff7f7f7f)),
              'title': TextStyle(color: Color(0xff56a9f5)),
              'title.class_': TextStyle(color: Color(0xffdcbdfb)),
              'title.class_.inherited__': TextStyle(color: Color(0xffdcbdfb)),
              'title.function_': TextStyle(color: Color(0xffdcbdfb)),
              'attr': TextStyle(color: Color(0xff6cb6ff)),
              'operator': TextStyle(color: Color(0xff6cb6ff)),
              'meta-string': TextStyle(color: Color(0xff96d0ff)),
              'formula': TextStyle(color: Color(0xff768390)),
            },
          ),
        ),
        controller: _controller,
        wordWrap: false,
        indicatorBuilder:
            (context, editingController, chunkController, notifier) {
          return Row(
            children: [
              DefaultCodeLineNumber(
                controller: editingController,
                notifier: notifier,
              ),
              DefaultCodeChunkIndicator(
                width: 20,
                controller: chunkController,
                notifier: notifier,
              )
            ],
          );
        },
        findBuilder: (context, controller, readOnly) => CodeFindPanelView(controller: controller, readOnly: readOnly),
        toolbarController: const ContextMenuControllerImpl(),
        sperator: Container(
            width: 1,
            color: Colors.blue
        ),
      ),
    );
  }
}

class _DefaultCodeAutocompleteListView extends StatefulWidget implements PreferredSizeWidget {

  static const double kItemHeight = 26;

  final ValueNotifier<CodeAutocompleteEditingValue> notifier;
  final ValueChanged<CodeAutocompleteResult> onSelected;

  const _DefaultCodeAutocompleteListView({
    required this.notifier,
    required this.onSelected,
  });

  @override
  Size get preferredSize => Size(
      250,
      // 2 is border size
      min(kItemHeight * notifier.value.prompts.length, 150) + 2
  );

  @override
  State<StatefulWidget> createState() => _DefaultCodeAutocompleteListViewState();

}

class _DefaultCodeAutocompleteListViewState extends State<_DefaultCodeAutocompleteListView> {

  @override
  void initState() {
    widget.notifier.addListener(_onValueChanged);
    super.initState();
  }

  @override
  void dispose() {
    widget.notifier.removeListener(_onValueChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: BoxConstraints.loose(widget.preferredSize),
        decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(6)
        ),
        child: AutoScrollListView(
          controller: ScrollController(),
          initialIndex: widget.notifier.value.index,
          scrollDirection: Axis.vertical,
          itemCount: widget.notifier.value.prompts.length,
          itemBuilder:(context, index) {
            final CodePrompt prompt = widget.notifier.value.prompts[index];
            final BorderRadius radius = BorderRadius.only(
              topLeft: index == 0 ? const Radius.circular(5) : Radius.zero,
              topRight: index == 0 ? const Radius.circular(5) : Radius.zero,
              bottomLeft: index == widget.notifier.value.prompts.length - 1 ? const Radius.circular(5) : Radius.zero,
              bottomRight: index == widget.notifier.value.prompts.length - 1 ? const Radius.circular(5) : Radius.zero,
            );
            return InkWell(
                borderRadius: radius,
                onTap: () {
                  widget.onSelected(widget.notifier.value.copyWith(
                      index: index
                  ).autocomplete);
                },
                child: Container(
                  width: double.infinity,
                  height: _DefaultCodeAutocompleteListView.kItemHeight,
                  padding: const EdgeInsets.only(
                      left: 5,
                      right: 5
                  ),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                      color: index == widget.notifier.value.index ? const Color.fromARGB(255, 255, 140, 0) : null,
                      borderRadius: radius
                  ),
                  child: RichText(
                    text: prompt.createSpan(context, widget.notifier.value.input),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                )
            );
          },
        )
    );
  }

  void _onValueChanged() {
    setState(() {
    });
  }

}

extension _CodePromptExtension on CodePrompt {

  InlineSpan createSpan(BuildContext context, String input) {
    const TextStyle style = TextStyle();
    final InlineSpan span = style.createSpan(
      value: word,
      anchor: input,
      color: Colors.blue,
      fontWeight: FontWeight.bold,
    );
    final CodePrompt prompt = this;
    if (prompt is CodeFieldPrompt) {
      return TextSpan(
          children: [
            span,
            TextSpan(
                text: ' ${prompt.type}',
                style: style.copyWith(
                    color: Colors.green
                )
            )
          ]
      );
    }
    if (prompt is CodeFunctionPrompt) {
      return TextSpan(
          children: [
            span,
            TextSpan(
                text: '(...) -> ${prompt.type}',
                style: style.copyWith(
                    color: Colors.green
                )
            )
          ]
      );
    }
    return span;
  }

}

extension _TextStyleExtension on TextStyle {

  InlineSpan createSpan({
    required String value,
    required String anchor,
    required Color color,
    FontWeight? fontWeight,
    bool casesensitive = false,
  }) {
    if (anchor.isEmpty) {
      return TextSpan(
        text: value,
        style: this,
      );
    }
    final int index;
    if (casesensitive) {
      index = value.indexOf(anchor);
    } else {
      index = value.toLowerCase().indexOf(anchor.toLowerCase());
    }
    if (index < 0) {
      return TextSpan(
        text: value,
        style: this,
      );
    }
    return TextSpan(
        children: [
          TextSpan(
              text: value.substring(0, index),
              style: this
          ),
          TextSpan(
              text: value.substring(index, index + anchor.length),
              style: copyWith(
                color: color,
                fontWeight: fontWeight,
              )
          ),
          TextSpan(
              text: value.substring(index + anchor.length),
              style: this
          )
        ]
    );
  }

}

class AutoScrollListView extends StatefulWidget {

  final ScrollController controller;
  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final int initialIndex;
  final Axis scrollDirection;

  const AutoScrollListView({
    super.key,
    required this.controller,
    required this.itemBuilder,
    required this.itemCount,
    this.initialIndex = 0,
    this.scrollDirection = Axis.vertical,
  });

  @override
  State<StatefulWidget> createState() => _AutoScrollListViewState();

}

class _AutoScrollListViewState extends State<AutoScrollListView> {

  late final List<GlobalKey> _keys;

  @override
  void initState() {
    _keys = List.generate(widget.itemCount, (index) => GlobalKey());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoScroll();
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant AutoScrollListView oldWidget) {
    if (widget.itemCount > oldWidget.itemCount) {
      _keys.addAll(List.generate(widget.itemCount - oldWidget.itemCount, (index) => GlobalKey()));
    } else if (widget.itemCount < oldWidget.itemCount) {
      _keys.sublist(oldWidget.itemCount - widget.itemCount);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoScroll();
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgets = [];
    for (int i = 0; i < widget.itemCount; i++) {
      widgets.add(Container(
        key: _keys[i],
        child: widget.itemBuilder(context, i),
      ));
    }
    return SingleChildScrollView(
      controller: widget.controller,
      scrollDirection: widget.scrollDirection,
      child: isHorizontal ? Row(
        children: widgets,
      ) : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      ),
    );
  }

  void _autoScroll() {
    final ScrollController controller = widget.controller;
    if (!controller.hasClients) {
      return;
    }
    if (controller.position.maxScrollExtent == 0) {
      return;
    }
    double pre = 0;
    double cur = 0;
    for (int i = 0; i < _keys.length; i++) {
      final RenderObject? obj = _keys[i].currentContext?.findRenderObject();
      if (obj == null || obj is! RenderBox) {
        continue;
      }
      if (isHorizontal) {
        double width = obj.size.width;
        if (i == widget.initialIndex) {
          cur = pre + width;
          break;
        }
        pre += width;
      } else {
        double height = obj.size.height;
        if (i == widget.initialIndex) {
          cur = pre + height;
          break;
        }
        pre += height;
      }
    }
    if (pre == cur) {
      return;
    }
    if (pre < widget.controller.offset) {
      controller.jumpTo(pre - 1);
    } else if (cur > controller.offset + controller.position.viewportDimension) {
      controller.jumpTo(cur - controller.position.viewportDimension);
    }
  }

  bool get isHorizontal => widget.scrollDirection == Axis.horizontal;

}
