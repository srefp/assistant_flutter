import 'package:assistant/components/win_text.dart';
import 'package:fluent_ui/fluent_ui.dart';

import '../app/windows_app.dart';

dialog({
  required String title,
  String content = '',
  barrierDismissible = true,
  Widget? child,
  double height = 50,
}) {
  showDialog(
      barrierDismissible: barrierDismissible,
      context: rootNavigatorKey.currentContext!,
      builder: (context) => ContentDialog(
            title: WinText(
              title,
            ),
            content: child ??
                SizedBox(
                  height: height,
                  child: Column(
                    children: [
                      WinText(
                        content,
                        selectable: true,
                      ),
                    ],
                  ),
                ),
            actions: [
              FilledButton(
                child: const WinText('确定'),
                onPressed: () {
                  Navigator.pop(context); // 关闭模态框
                },
              ),
            ],
          ));
}
