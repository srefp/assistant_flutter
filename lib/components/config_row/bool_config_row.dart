import 'package:assistant/components/config_item.dart';
import 'package:assistant/components/title_with_sub.dart';
import 'package:fluent_ui/fluent_ui.dart';

import '../../config/auto_tp_config.dart';

typedef ValueCallback = bool Function();

class BoolConfigItem extends ConfigItem {
  final ValueCallback valueCallback;

  BoolConfigItem({
    required super.title,
    super.subTitle = '',
    required super.valueKey,
    required this.valueCallback,
  });
}

class BoolConfigRow extends StatefulWidget {
  final BoolConfigItem item;
  final String lightText;

  const BoolConfigRow({
    super.key,
    required this.item,
    this.lightText = '',
  });

  @override
  State<BoolConfigRow> createState() => _BoolConfigRowState();
}

class _BoolConfigRowState extends State<BoolConfigRow> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: TitleWithSub(
              title: widget.item.title,
              subTitle: widget.item.subTitle,
              lightText: widget.lightText,
            ),
          ),
          SizedBox(
            width: 12,
          ),
          SizedBox(
            child: ToggleSwitch(
              checked: widget.item.valueCallback(),
              onChanged: (value) {
                setState(() {
                  AutoTpConfig.to.save(widget.item.valueKey!, value);
                });
              },
            ),
          )
        ],
      ),
    );
  }
}
