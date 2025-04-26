import 'package:assistant/notifier/config_model.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';

import '../components/win_text.dart';

class ConfigPage extends StatelessWidget {
  const ConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConfigModel>(builder: (context, model, child) {
      return ListView(
          padding: EdgeInsets.all(20),
          children: [
            WinText(
              '配置',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
          ]
      );
    });
  }
}
