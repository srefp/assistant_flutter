import 'package:assistant/component/model/config_item.dart';
import 'package:fluent_ui/fluent_ui.dart';

import '../../app/config/auto_tp_config.dart';
import '../title_with_sub.dart';

typedef ValueCallback = int Function();

class DoubleConfigItem extends ConfigItem {
  @override
  String get valueKey => super.valueKey!;
  final double Function() valueCallback;

  DoubleConfigItem({
    required super.title,
    super.subTitle = '',
    required super.valueKey,
    required this.valueCallback,
  });
}

class DoubleConfigRow extends StatelessWidget {
  final DoubleConfigItem item;
  final String lightText;

  const DoubleConfigRow({
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
            child: NumberBox(
              mode: SpinButtonPlacementMode.none,
              value: item.valueCallback(),
              onChanged: (value) => AutoTpConfig.to.save(item.valueKey, value),
            ),
          )
        ],
      ),
    );
  }
}
