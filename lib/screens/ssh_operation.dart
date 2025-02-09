import 'package:assistant/components/win_text.dart';
import 'package:assistant/ssh/ssh_connector.dart';
import 'package:fluent_ui/fluent_ui.dart';

class SshOperation extends StatelessWidget {
  const SshOperation({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(20),
      children: [
        WinText(
          'SSH连接',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            SizedBox(
              width: 100,
              child: Button(
                child: WinText('执行'),
                onPressed: () {
                  executeSSH('pwd');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
