import 'package:assistant/auto_gui/key_mouse_util.dart';
import 'package:assistant/manager/screen_manager.dart';
import 'package:assistant/win32/toast.dart';
import 'package:fluent_ui/fluent_ui.dart';

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
                  KeyMouseUtil.showCoordinate();
                },
              ),
            ),
            SizedBox(width: 16),
            SizedBox(
              width: 120,
              child: Button(
                child: WinText('获取窗口句柄'),
                onPressed: () {
                  ScreenManager.instance.refreshWindowHandle();
                  showToast('句柄： ${ScreenManager.instance.hWnd ?? '空'}');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
