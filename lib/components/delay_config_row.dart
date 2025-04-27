import 'package:assistant/components/title_with_sub.dart';
import 'package:fluent_ui/fluent_ui.dart';

import '../config/auto_tp_config.dart';

typedef ValueCallback = int Function();

class DelayConfigItem {
  final String title;
  final String subTitle;
  final String valueKey;
  final ValueCallback valueCallback;

  DelayConfigItem({
    required this.title,
    required this.subTitle,
    required this.valueKey,
    required this.valueCallback,
  });
}

class DelayConfigRow extends StatelessWidget {
  final DelayConfigItem item;
  final String lightText;

  const DelayConfigRow({
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
              value: item.valueCallback(),
              onChanged: (value) => AutoTpConfig.to.save(item.valueKey, value),
            ),
          )
        ],
      ),
    );
  }
}
