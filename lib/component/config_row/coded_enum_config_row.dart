import 'package:assistant/component/box/highlight_combo_box.dart';
import 'package:assistant/component/component.dart';
import 'package:assistant/constant/constant.dart';
import 'package:fluent_ui/fluent_ui.dart';

import '../../app/config/auto_tp_config.dart';
import '../model/config_item.dart';

class CodedEnumConfigItem<T extends CodedEnum> extends ConfigItem {
  final T Function() valueCallback;
  final List<T> items;

  @override
  String get valueKey => super.valueKey!;

  CodedEnumConfigItem({
    required super.title,
    super.subTitle = '',
    required super.valueKey,
    required this.valueCallback,
    required this.items,
  });
}

class CodedEnumConfigRow<T extends CodedEnum> extends StatefulWidget {
  final CodedEnumConfigItem<T> item;
  final String lightText;

  const CodedEnumConfigRow({
    super.key,
    required this.item,
    this.lightText = '',
  });

  @override
  State<CodedEnumConfigRow<T>> createState() => _CodedEnumConfigRowState<T>();
}

class _CodedEnumConfigRowState<T extends CodedEnum> extends State<CodedEnumConfigRow<T>> {
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
            height: 34,
            width: 200,
            child: HighlightComboBox(
              value: widget.item.valueCallback().resourceId,
              items: widget.item.items.map<String>((e) => e.resourceId).toList(),
              onChanged: (value) {
                setState(() {
                  AutoTpConfig.to.save(
                    widget.item.valueKey,
                    EnumUtil.fromResourceId<T>(value, widget.item.items).code,
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
