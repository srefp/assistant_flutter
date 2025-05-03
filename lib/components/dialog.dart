import 'package:assistant/components/win_text.dart';
import 'package:fluent_ui/fluent_ui.dart';

dialog(
  BuildContext context, {
  required String title,
  String content = '',
  Widget? child,
}) {
  showDialog(
      context: context,
      builder: (context) => ContentDialog(
            title: WinText(title),
            content: child ??
                SizedBox(
                  height: 50,
                  child: Column(
                    children: [
                      WinText(content),
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
