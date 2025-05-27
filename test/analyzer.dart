void main() {
  String input = '''
  // 这是一个注释
  123
abc{ hello(); }
bde{
  while (true) {
    a();
  }
}
''';

  List<Map<String, String>> blocks = extractTopLevelBlocks(input);

  for (var block in blocks) {
    print('-----------');
    print('name: ${block['name']} block ${block['block']}');
  }
}

List<Map<String, String>> extractTopLevelBlocks(String code) {
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

        // 向前查找名字
        int nameEnd = startIdx!;
        int nameStart = nameEnd - 1;

        while (nameStart >= 0 &&
            (RegExp(r'[a-zA-Z0-9_\$]').hasMatch(code[nameStart]))) {
          nameStart--;
        }
        nameStart++;

        String name = code.substring(nameStart, nameEnd).trim();

        result.add({'name': name, 'block': block});
        startIdx = null;
      }
    }
  }

  return result;
}