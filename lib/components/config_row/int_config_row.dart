import 'package:assistant/components/title_with_sub.dart';
import 'package:fluent_ui/fluent_ui.dart';

import '../../config/auto_tp_config.dart';

typedef ValueCallback = int Function();

class IntConfigItem {
  final String title;
  final String subTitle;
  final String valueKey;
  final ValueCallback valueCallback;

  IntConfigItem({
    required this.title,
    this.subTitle = '',
    required this.valueKey,
    required this.valueCallback,
  });
}

class IntConfigRow extends StatelessWidget {
  final IntConfigItem item;
  final String lightText;

  const IntConfigRow({
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
