import 'package:assistant/constants/coded_enum.dart';

class EnumUtil {
  static T fromCode<T extends CodedEnum>(int code, List<T> list) {
    return list.firstWhere((element) => element.code == code,
        orElse: () => list.first);
  }
}
