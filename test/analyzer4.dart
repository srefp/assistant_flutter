void main() {
  String input = '''
/*
 * 这是一个多行注释
 * 不会影响 abc.def.g hi 的提取
 */
abc // 注释不影响
 
  
  .def
  .ghi'"
{
  hello();
}

bde {
  while (/* 内部注释 */ true) {
    a();
  }
}
''';
  try {
    List<BlockItem> blocks = extractTopLevelBlocks(input);

    for (var block in blocks) {
      print('-----------');
      print('${block.name} ${block.code}');
    }
  } catch (e) {
    print(e);
  }
}

class BlockItem {
  final String name;
  final String code;

  BlockItem(this.name, this.code);
}

List<BlockItem> extractTopLevelBlocks(String code) {
  // 第一步：去除所有注释（包括 // 和 /* */）
  code = removeComments(code);

  List<BlockItem> result = [];
  int braceDepth = 0;
  int? startIdx;

  for (int i = 0; i < code.length; i++) {
    if (code[i] == '{') {
      if (braceDepth == 0) {
        startIdx = i;
      }
      braceDepth++;
    } else if (code[i] == '}') {
      if (braceDepth == 0) {
        throw FormatException("发现多余的 '}' 在位置 $i");
      }
      braceDepth--;
      if (braceDepth == 0 && startIdx != null) {
        // 提取 {} 内容，并去除前后空格/换行
        String block = code.substring(startIdx + 1, i).trim();
        String minifiedBlock = minifyCode(block);

        // 向前查找名称
        int nameEnd = startIdx;
        int nameStart = nameEnd - 1;

        // 跳过空格和换行
        while (nameStart >= 0 &&
            (code[nameStart].trim().isEmpty || code[nameStart] == '\n')) {
          nameStart--;
        }

        // 开始收集合法名称字符
        int collectPos = nameStart;
        while (collectPos >= 0 && !'{}'.contains(code[collectPos])) {
          collectPos--;
        }
        collectPos++;

        String rawName = code.substring(collectPos, nameEnd).replaceAll('"', '').replaceAll("'", '').trim();

        // 将多行名称合并为一行，用空格连接
        String normalizedName =
            rawName.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ');

        result.add(BlockItem(normalizedName, minifiedBlock));
        startIdx = null;
      }
    }
  }

  if (braceDepth > 0) {
    throw FormatException("文件中有未闭合的大括号（缺少 $braceDepth 个 '}'）");
  }

  return result;
}

String minifyCode(String code) {
  // 去除所有换行符和前后空格
  String result = code.replaceAll('\n', '').trim();

  // 替换多个连续空白为单个空格
  result = result.replaceAll(RegExp(r'\s+'), ' ');

  // 可选：去除无意义空格（比如操作符周围的空格）
  // 如：while ( true ) → while(true)
  result = result
      .replaceAll(RegExp(r'\(\s*'), '(')
      .replaceAll(RegExp(r'\s*\)'), ')')
      .replaceAll(RegExp(r'\{\s*'), '{')
      .replaceAll(RegExp(r'\s*\}'), '}')
      .replaceAll(RegExp(r';\s*'), ';')
      .replaceAll(RegExp(r',\s*'), ',');

  return result;
}

/// 删除所有注释（包括 // 和 /* */）
String removeComments(String code) {
  StringBuffer result = StringBuffer();
  int i = 0;
  int length = code.length;

  while (i < length) {
    if (i + 1 < length && code[i] == '/' && code[i + 1] == '/') {
      // 单行注释：跳到行尾
      i += 2;
      while (i < length && code[i] != '\n') {
        i++;
      }
    } else if (i + 1 < length && code[i] == '/' && code[i + 1] == '*') {
      // 多行注释：跳到结束
      i += 2;
      bool closed = false;
      while (i + 1 < length) {
        if (code[i] == '*' && code[i + 1] == '/') {
          i += 2;
          closed = true;
          break;
        }
        i++;
      }
      if (!closed) {
        // 未闭合的注释，防止越界
        i = length;
      }
    } else {
      // 普通字符，添加到结果中
      result.write(code[i]);
      i++;
    }
  }

  return result.toString();
}
