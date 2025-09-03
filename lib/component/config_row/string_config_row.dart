import 'package:fluent_ui/fluent_ui.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

import '../../app/config/auto_tp_config.dart';
import '../../app/module/config/config_model.dart';
import '../box/win_text_box.dart';
import '../model/config_item.dart';
import '../title_with_sub.dart';

class StringConfigItem extends ConfigItem {
  final int type;
  final HotKey Function()? keyItemCallback;
  final HotKeyHandler? keyDownHandler;
  final String Function() valueCallback;

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
