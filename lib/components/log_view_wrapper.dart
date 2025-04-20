import 'package:assistant/config/setting_config.dart';
import 'package:assistant/notifier/log_model.dart';
import 'package:assistant/notifier/record_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/languages/ini.dart';

import 'button_with_icon.dart';

class LogViewWrapper extends StatelessWidget {
  final Widget child;

  const LogViewWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.vertical,
      children: [
        Expanded(child: child),
        SettingConfig.to.getLogShow()
            ? const LogView()
            : const SizedBox(width: 0, height: 0),
      ],
    );
  }
}

class LogView extends StatelessWidget {
  const LogView({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: Consumer<LogModel>(builder: (context, model, child) {
        return Column(
          children: [
            SizedBox(
              height: 34,
              child: Row(
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Consumer<RecordModel>(builder: (context, model, child) {
                      return SizedBox(
                        height: 34,
                        child: ButtonWithIcon(
                          icon: model.isRecording ? Icons.stop : Icons.play_arrow,
                          text: model.isRecording ? '停止录制' : '开始录制',
                          onPressed: () {
                            if (model.isRecording) {
                              model.stopRecord();
                            } else {
                              model.startRecord();
                            }
                          },
                        ),
                      );
                    }
                  ),
                  SizedBox(
                    height: 34,
                    child: ButtonWithIcon(
                      icon: Icons.clear,
                      text: '清空',
                      onPressed: () {
                        model.clear();
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CodeEditor(
                style: CodeEditorStyle(
                  fontFamily: 'Consolas',
                  fontSize: 16,
                  textColor: const Color(0xffbcbec4),
                  codeTheme: CodeHighlightTheme(
                    languages: {
                      'javascript': CodeHighlightThemeMode(mode: langIni)
                    },
                    theme: {
                      'root': TextStyle(
                          backgroundColor: Color(0xff2b2b2b),
                          color: Color(0xffbababa)),
                      'strong': TextStyle(color: Color(0xffa8a8a2)),
                      'emphasis': TextStyle(
                          color: Color(0xffa8a8a2),
                          fontStyle: FontStyle.italic),
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
                      'selector-pseudo':
                          TextStyle(color: Color(0xffe0c46c)),
                      'template-tag': TextStyle(color: Color(0xffe0c46c)),
                      'template-variable':
                          TextStyle(color: Color(0xffe0c46c)),
                      'addition': TextStyle(color: Color(0xffe0c46c)),
                      'comment': TextStyle(color: Color(0xff7f7f7f)),
                      'deletion': TextStyle(color: Color(0xff7f7f7f)),
                      'meta': TextStyle(color: Color(0xff7f7f7f)),
                      'title': TextStyle(color: Color(0xff56a9f5)),
                      'title.class_': TextStyle(color: Color(0xffdcbdfb)),
                      'title.class_.inherited__':
                          TextStyle(color: Color(0xffdcbdfb)),
                      'title.function_':
                          TextStyle(color: Color(0xffdcbdfb)),
                      'attr': TextStyle(color: Color(0xff6cb6ff)),
                      'operator': TextStyle(color: Color(0xff6cb6ff)),
                      'meta-string': TextStyle(color: Color(0xff96d0ff)),
                      'formula': TextStyle(color: Color(0xff768390)),
                    },
                  ),
                ),
                controller: model.logController,
              ),
            ),
          ],
        );
      }),
    );
  }
}
