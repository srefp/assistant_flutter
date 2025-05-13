import 'package:assistant/components/title_with_sub.dart';
import 'package:assistant/notifier/config_model.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

import '../config/auto_tp_config.dart';

typedef ValueCallback = String Function();
typedef KeyItemCallback = HotKey Function();

class StringConfigItem {
  final int type;
  final KeyItemCallback? keyItemCallback;
  final HotKeyHandler? keyDownHandler;
  final String title;
  final String subTitle;
  final String valueKey;
  final ValueCallback valueCallback;

  StringConfigItem({
    this.type = listen,
    required this.title,
    this.subTitle = '',
    required this.valueKey,
    required this.valueCallback,
    this.keyItemCallback,
    this.keyDownHandler,
  });
}

class StringConfigRow extends StatelessWidget {
  final StringConfigItem item;
  final String lightText;

  const StringConfigRow({
    super.key,
    required this.item,
    this.lightText = '',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: TitleWithSub(
              title: item.title,
              subTitle: item.subTitle,
              lightText: lightText,
            ),
          ),
          SizedBox(
            width: 12,
          ),
          SizedBox(
            height: 34,
            width: 200,
            child: TextBox(
              controller: TextEditingController(text: item.valueCallback()),
              onChanged: (value) => AutoTpConfig.to.save(item.valueKey, value),
            ),
          )
        ],
      ),
    );
  }
}
