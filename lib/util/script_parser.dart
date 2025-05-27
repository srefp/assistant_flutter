import 'package:assistant/util/route_util.dart';

class BlockItem {
  final String? name;
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

        result.add(BlockItem(normalizedName.isNotEmpty ? normalizedName : null, minifiedBlock));
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

// 第一代脚本解析器
List<TpPoint> parseV1(String content) {
  final RegExp keyValuePairRegex =
      RegExp(r'(\w+):\s*((?:"[^"]*")|(?:\[.*?\])|(?:-?\d+(?:\.\d+)?))');

  final Map<String, List<int>> areaMap = {
    'mengde': [1, 1],
    'md': [1, 1],
    'liyue': [1, 2],
    'ly': [1, 2],
    'daoqi': [2, 1],
    'dq': [2, 1],
    'xumi': [2, 2],
    'xm': [2, 2],
    'fengdan': [3, 1],
    'fd': [3, 1],
    'nata': [3, 2],
    'nt': [3, 2],
    'yuanxiagong': [4, 1],
    'yxg': [4, 1],
    'cengyanjuyuan': [4, 2],
    'cyjy': [4, 2],
    'cy': [4, 2],
  };

  final Map<String, List<int>> bossMap = {
    'wxzl': [1, 1],
    'wxzf': [1, 2],
    'jds': [1, 3],
    'bfdwhbldlz': [2, 1],
    'lw': [2, 1],
    'wxzy': [2, 2],
    'csjl': [2, 3],
    'bys': [3, 1],
    'gylx': [3, 2],
    'wxzb': [3, 3],
    'mojg': [4, 1],
    'wxzh': [4, 2],
    'hcjgzl': [4, 3],
    'wxzt': [4, 3],
    'wxzs': [5, 1],
    'lyqx': [5, 2],
    'hjws': [5, 3],
    'shlxzq': [6, 1],
    // ... 其他 BossMap 项
  };

  List<TpPoint> res = [];
  List<String> lines = content.split('\n');
  for (String lineItem in lines) {
    String line = lineItem.trim();
    if (line.contains('--')) {
      line = line.substring(0, line.indexOf('--')).trim();
    }

    if (line.isEmpty) {
      continue;
    }

// 使用 String 的 split 方法结合正则表达式
    final matches = keyValuePairRegex.allMatches(lineItem);
    final values = matches.expand((match) => [match[1]!, match[2]!]).toList();
    List<String> keyValues = values.where((s) => s.isNotEmpty).toList();
    int len = keyValues.length;
    TpPoint tpPoint = TpPoint();

    for (int index = 0; index < len; index += 2) {
      String key = keyValues[index];
      String value = keyValues[index + 1];

      if (key == RouteKeys.id) {
        tpPoint.id = RouteUtil.stringToString(value);
      } else if (key == RouteKeys.boss) {
        if (value.startsWith('[')) {
          tpPoint.boss = RouteUtil.stringToIntList(value);
        } else {
          tpPoint.boss = bossMap[RouteUtil.stringToString(value)];
        }
      } else if (key == RouteKeys.delayBoss) {
        tpPoint.delayBook = RouteUtil.stringToInt(value);
      } else if (key == RouteKeys.delayTrack) {
        tpPoint.delayTrack = RouteUtil.stringToInt(value);
      } else if (key == RouteKeys.delayMap) {
        tpPoint.delayMap = RouteUtil.stringToInt(value);
      } else if (key == RouteKeys.delayTp) {
        tpPoint.delayTp = RouteUtil.stringToInt(value);
      } else if (key == RouteKeys.delayConfirm) {
        tpPoint.delayConfirm = RouteUtil.stringToInt(value);
      } else if (key == RouteKeys.domain) {
        tpPoint.domain = RouteUtil.stringToBool(value);
      } else if (key == RouteKeys.temporary) {
        tpPoint.temporary = RouteUtil.stringToBool(value);
      } else if (key == RouteKeys.script) {
        tpPoint.script = RouteUtil.stringToString(value);
      } else if (key == RouteKeys.scriptD) {
        tpPoint.script = RouteUtil.stringToString(value);
      } else if (key == RouteKeys.pos) {
        tpPoint.pos = RouteUtil.stringToIntList(value);
      } else if (key == RouteKeys.narrow) {
        tpPoint.narrow = RouteUtil.stringToInt(value);
      } else if (key == RouteKeys.select) {
        tpPoint.select = RouteUtil.stringToBool(value);
      } else if (key == RouteKeys.flower) {
        tpPoint.flower = RouteUtil.stringToBool(value);
      } else if (key == RouteKeys.drag) {
        tpPoint.drag = RouteUtil.stringToIntList(value);
      } else if (key == RouteKeys.posD) {
        tpPoint.posD = RouteUtil.stringToIntList(value);
      } else if (key == RouteKeys.narrowD) {
        tpPoint.narrowD = RouteUtil.stringToInt(value);
      } else if (key == RouteKeys.selectD) {
        tpPoint.selectD = RouteUtil.stringToInt(value);
      } else if (key == RouteKeys.flowerD) {
        tpPoint.flowerD = RouteUtil.stringToBool(value);
      } else if (key == RouteKeys.dragD) {
        tpPoint.dragD = RouteUtil.stringToIntList(value);
      } else if (key == RouteKeys.area) {
        if (value.startsWith('[')) {
          tpPoint.area = RouteUtil.stringToIntList(value);
        } else {
          tpPoint.area = areaMap[RouteUtil.stringToString(value)];
        }
      } else if (key == RouteKeys.posA) {
        tpPoint.posA = RouteUtil.stringToIntList(value);
      } else if (key == RouteKeys.narrowA) {
        tpPoint.narrowA = RouteUtil.stringToInt(value);
      } else if (key == RouteKeys.selectA) {
        tpPoint.selectA = RouteUtil.stringToInt(value);
      } else if (key == RouteKeys.flowerA) {
        tpPoint.flowerA = RouteUtil.stringToBool(value);
      } else if (key == RouteKeys.dragA) {
        tpPoint.dragA = RouteUtil.stringToIntList(value);
      } else if (key == RouteKeys.name) {
        tpPoint.name = RouteUtil.stringToString(value);
      } else if (key == RouteKeys.comment) {
        tpPoint.comment = RouteUtil.stringToString(value);
      }
    }

    res.add(tpPoint);
  }

  return res;
}
