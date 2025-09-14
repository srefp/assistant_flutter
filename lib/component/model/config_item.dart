import 'package:assistant/component/config_row/bool_config_row.dart';
import 'package:assistant/component/config_row/int_config_row.dart';
import 'package:fluent_ui/fluent_ui.dart';

import '../config_row/coded_enum_config_row.dart';
import '../config_row/string_config_row.dart';

class ConfigItem {
  final String title;
  final String subTitle;
  final String? valueKey;

  ConfigItem({
    required this.title,
    required this.subTitle,
    this.valueKey,
  });
}

Widget renderItem(ConfigItem item, String lightText) {
  if (item is IntConfigItem) {
    return IntConfigRow(
      item: item,
      lightText: lightText,
    );
  } else if (item is BoolConfigItem) {
    return BoolConfigRow(
      item: item,
      lightText: lightText,
    );
  } else if (item is StringConfigItem) {
    return StringConfigRow(
      item: item,
      lightText: lightText,
    );
  } else if (item is CodedEnumConfigItem) {
    return CodedEnumConfigRow(
      item: item,
      lightText: lightText,
    );
  }
  return SizedBox(
    width: 0,
    height: 0,
  );
}
