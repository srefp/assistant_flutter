import 'package:assistant/components/config_item.dart';
import 'package:assistant/components/title_with_sub.dart';
import 'package:assistant/components/win_text_box.dart';
import 'package:assistant/notifier/config_model.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

import '../../config/auto_tp_config.dart';

typedef ValueCallback = String Function();
typedef KeyItemCallback = HotKey Function();

class StringConfigItem extends ConfigItem {
  final int type;
  final KeyItemCallback? keyItemCallback;
  final HotKeyHandler? keyDownHandler;
  final ValueCallback valueCallback;

  StringConfigItem({
    this.type = listen,
    required super.title,
    super.subTitle = '',
    required super.valueKey,
    required this.valueCallback,
    this.keyItemCallback,
    this.keyDownHandler,
  });
}

class StringConfigRow extends StatelessWidget {
  final StringConfigItem item;
  final String lightText;
  final Widget rightWidget;

  const StringConfigRow({
    super.key,
    required this.item,
    this.lightText = '',
    this.rightWidget = const SizedBox(),
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
          rightWidget,
          SizedBox(
            width: 12,
          ),
          SizedBox(
            height: 34,
            width: 200,
            child: WinTextBox(
              controller: TextEditingController(text: item.valueCallback()),
              onChanged: (value) => AutoTpConfig.to.save(item.valueKey!, value),
            ),
          )
        ],
      ),
    );
  }
}
