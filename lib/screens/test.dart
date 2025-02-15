import 'package:assistant/auto_gui/km_util.dart';
import 'package:assistant/components/code_editor.dart';
import 'package:assistant/screens/virtual_screen.dart';
import 'package:assistant/win32/toast.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';

import '../components/win_text.dart';

class Test extends StatelessWidget {
  const Test({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(20),
      children: [
        WinText(
          '测试',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            SizedBox(
              width: 100,
              child: Button(
                child: WinText('弹出消息框'),
                onPressed: () {
                  List<int> point = getMousePosition();
                  List<int> virtualPos = getVirtualPos(point);
                  showToast('已复制坐标: ${virtualPos[0]}, ${virtualPos[1]}');
                },
              ),
            ),
            SizedBox(
              height: 600,
            ),
          ],
        ),
      ],
    );
  }
}
