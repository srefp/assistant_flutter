void main() {
  String input = '''
// 这是一个注释
abc // 注释不影响
def
ghi
{
  hello();
}

bde {
  // 内部注释
  while (true) {
    a();
  }
}
''';

  List<Map<String, String>> blocks = extractTopLevelBlocks(input);

  for (var block in blocks) {
    print('-----------');
    print('name: ${block['name']}, block: ${block['block']}');
  }
}

List<Map<String, String>> extractTopLevelBlocks(String code) {
  // 第一步：去除所有 // 注释
  code = removeLineComments(code);

  List<Map<String, String>> result = [];
  int braceDepth = 0;
  int? startIdx;

  for (int i = 0; i < code.length; i++) {
    if (code[i] == '{') {
      if (braceDepth == 0) {
        startIdx = i;
      }
      braceDepth++;
    } else if (code[i] == '}') {
      braceDepth--;
      if (braceDepth == 0 && startIdx != null) {
        int endIdx = i + 1;
        String block = code.substring(startIdx, endIdx);

        // 向前查找名称
        int nameEnd = startIdx!;
        int nameStart = nameEnd - 1;

        // 向前跳过空格和换行
        while (nameStart >= 0 &&
            (code[nameStart].trim().isEmpty || code[nameStart] == '\n')) {
          nameStart--;
        }

        // 开始收集合法名称字符（字母、数字、符号等）
        int collectPos = nameStart;
        while (collectPos >= 0 &&
            !'{}()[]+-*/%=<>,.!@#\$^&*|~?:'.contains(code[collectPos])) {
          collectPos--;
        }
        collectPos++;

        String rawName = code.substring(collectPos, nameEnd).trim();

        // 将多行名称合并为一行，用空格连接
        String normalizedName = rawName.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ');

        result.add({'name': normalizedName, 'block': block});
        startIdx = null;
      }
    }
  }

  return result;
}

String removeLineComments(String code) {
  final lines = code.split('\n');
  final cleanedLines = lines.map((line) {
    final commentIndex = line.indexOf('//');
    if (commentIndex == -1) return line;
    return line.substring(0, commentIndex);
  }).where((line) => line.trim().isNotEmpty); // 去掉全空行
  return cleanedLines.join('\n');
}