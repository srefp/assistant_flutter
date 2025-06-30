/// 将特定格式的函数调用转换为sendMessage格式
/// 示例输入：click([123, 456], 60);
/// 示例输出：sendMessage('click', JSON.stringify([[123, 456], 60]));
String convertFunctionCalls(String input) {
  // 正则表达式说明：
  // - (\w+) 匹配函数名（如click）
  // - \s* 匹配括号前后可能的空格
  // - (.*?) 非贪婪匹配参数部分（处理任意参数内容）
  final regex = RegExp(r'(\w+)\s*\(\s*(.*?)\s*\)\s*;');

  // 获取所有匹配项并按结束位置逆序排序（避免替换影响后续匹配位置）
  final matches = regex.allMatches(input).toList()
    ..sort((a, b) => b.end.compareTo(a.end)); // 逆序处理

  String result = input;
  for (final match in matches) {
    final functionName = match.group(1)!;  // 提取函数名（如click）
    final parameters = match.group(2)!;    // 提取参数部分（如[123, 456], 60）

    // 生成替换内容
    final replacement = "sendMessage('$functionName', JSON.stringify([$parameters]));";

    // 替换原始字符串中的匹配区间
    result = result.replaceRange(match.start, match.end, replacement);
  }
  return result;
}

void main() {
  final res = convertFunctionCalls('click([123, 456], 60); hello(); mUp(1); while (true) { print("hello"); }');
  print(res);
}
