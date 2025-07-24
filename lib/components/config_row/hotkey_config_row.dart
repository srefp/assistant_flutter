import 'package:assistant/components/title_with_sub.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

import '../../config/hotkey_config.dart';
import '../../notifier/config_model.dart';
import '../config_item.dart';

typedef ValueCallback = String Function();
typedef KeyItemCallback = HotKey Function();

class HotkeyConfigItem extends ConfigItem {
  final int type;
  final KeyItemCallback? keyItemCallback;
  final HotKeyHandler? keyDownHandler;
  final ValueCallback? valueCallback;
  final bool Function()? enabledCallback;
  final String? enabledKey;

  HotkeyConfigItem({
    this.type = listen,
    required super.title,
    super.subTitle = '',
    super.valueKey,
    this.valueCallback,
    this.keyItemCallback,
    this.keyDownHandler,
    this.enabledCallback,
    this.enabledKey,
  });
}

class HotkeyConfigRow extends StatefulWidget {
  final HotkeyConfigItem item;
  final String lightText;

  const HotkeyConfigRow({
    super.key,
    required this.item,
    this.lightText = '',
  });

  @override
  State<HotkeyConfigRow> createState() => _HotkeyConfigRowState();
}

class _HotkeyConfigRowState extends State<HotkeyConfigRow> {
  @override
  Widget build(BuildContext context) {
    return TitleWithSub(
      title: widget.item.title,
      subTitle: widget.item.subTitle,
      lightText: widget.lightText,
      rightWidget: Row(
        children: [
          if (widget.item.valueKey != null)
            HotkeyBox(
              value: widget.item.valueCallback?.call(),
              global: widget.item.type == global,
              hotKey: widget.item.keyItemCallback?.call(),
              onValueChanged: (value) =>
                  HotkeyConfig.to.save(widget.item.valueKey!, value),
              onGlobalValueChanged: (value) => hotKeyManager.register(
                  widget.item.keyItemCallback!(),
                  keyDownHandler: widget.item.keyDownHandler),
            ),
          if (widget.item.enabledKey != null)
            SizedBox(
              width: 20,
            ),
          if (widget.item.enabledKey != null)
            ToggleSwitch(
              checked: widget.item.enabledCallback!(),
              onChanged: (value) => setState(() {
                HotkeyConfig.to.save(widget.item.enabledKey!, value);
              }),
            ),
        ],
      ),
    );
  }
}
