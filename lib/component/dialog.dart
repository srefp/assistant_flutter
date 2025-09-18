import 'package:fluent_ui/fluent_ui.dart';

import '../app/windows_app.dart';
import 'component.dart';

dialog({
  required String title,
  String content = '',
  barrierDismissible = true,
  Widget? child,
  double height = 180,
  double width = 368,
  List<Widget>? actions,
}) {
  showDialog(
    barrierDismissible: barrierDismissible,
    context: rootNavigatorKey.currentContext!,
    builder: (context) => ContentDialog(
      constraints: BoxConstraints.tightFor(width: width),
      title: WinText(
        title,
      ),
      content: SizedBox(
        height: height,
        child: child ??
            ListView(
              children: [
                WinText(
                  content,
                  selectable: true,
                ),
              ],
            ),
      ),
      actions: actions ??
          [
            FilledButton(
              child: const WinText('确定'),
              onPressed: () {
                Navigator.pop(context); // 关闭模态框
              },
            ),
          ],
    ),
  );
}
