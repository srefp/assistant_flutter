import 'package:assistant/util/db_helper.dart';

void main() {
  // 模拟多行输入字符串
  String input = '123\n// 注释行\nname: "hello", script: "abc();" // 注释\n普通文本行 name: "world", script: "def();" 其他内容';

  // 解析并转换
  String result = convertV2(input);

  // 输出结果
  print(result);
}
