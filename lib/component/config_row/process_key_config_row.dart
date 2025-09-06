import 'package:assistant/component/config_row/string_config_row.dart';
import 'package:fluent_ui/fluent_ui.dart';

import '../../app/config/auto_tp_config.dart';
import '../../app/config/hotkey_config.dart';
import '../box/win_text_box.dart';
import '../dialog.dart';
import '../title_with_sub.dart';

class ProcessKeyConfigRow extends StatelessWidget {
  final StringConfigItem item;
  final String lightText;

  const ProcessKeyConfigRow({
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
            child: WinTextBox(
              controller: TextEditingController(text: item.valueCallback()),
              onChanged: (value) {
                if (crackWithHotkey(value)) {
                  dialog(title: '注意', content: '该键位已被耕地机快捷键占用');
                }
                AutoTpConfig.to.save(item.valueKey!, value);
              },
            ),
          )
        ],
      ),
    );
  }
}

bool crackWithHotkey(String key) {
  final hotkeys = [
    HotkeyConfig.to.getStartStopKey(),
    HotkeyConfig.to.getShowCoordsKey(),
    HotkeyConfig.to.getHalfTp(),
    HotkeyConfig.to.getTpNext(),
    HotkeyConfig.to.getEatFoodKey(),
  ];
  return hotkeys.contains(key);
}
