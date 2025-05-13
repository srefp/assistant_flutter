import 'dart:math';

import 'package:date_format/date_format.dart';
import 'package:intl/intl.dart';
import 'package:lpinyin/lpinyin.dart';

import '../util/date_utils.dart';

/// String扩展类
extension StringExtension on String {
  /// 更改后缀名
  String replaceExtension(String oldExt, String newExt) {
    return replaceRange(length - oldExt.length, length, newExt);
  }

  /// 匹配日期
  String get matchDate {
    late DateTime date;
    try {
      date = DateTime.parse(this);
    } catch (e) {
      return '未知日期';
    }
    final now = DateTime.now();
    if (sameDay(date, now)) {
      return '今天';
    } else if (sameDay(date, now.add(Duration(days: 1)))) {
      return '明天';
    } else if (sameDay(date, now.add(Duration(days: 2)))) {
      return '后天';
    } else if (sameDay(date, now.subtract(Duration(days: 1)))) {
      return '昨天';
    }
    return formatDate(date, [yyyy, '-', mm, '-', dd]);
  }

  /// 获取文件夹
  String get directory {
    int index = lastIndexOf('/') + 1;
    index = max(index, lastIndexOf('\\') + 1);
    return substring(0, index);
  }

  /// 获取文件名
  String get fileName {
    int index = lastIndexOf('/') + 1;
    index = max(index, lastIndexOf('\\') + 1);
    return substring(index);
  }

  /// 获取文件后缀名
  String get fileExtension {
    List<String> splits = fileName.split('.');
    if (splits.length == 1) {
      return '';
    }
    return splits.last;
  }

  /// 转换为 int list
  List<int> get getIntList {
    List<String> list = split(',');
    return list.map((e) => int.parse(e)).toList();
  }

  /// 转换为 int set
  Set<int> get getIntSet {
    List<String> list = split(',');
    return list.map((e) => int.parse(e)).toSet();
  }

  /// 转换为日期
  DateTime dateTime({required String format}) {
    return DateFormat(format).parse(this);
  }

  /// 获取字符串拼音首字母
  String get pinyinShort {
    /// 拼音分隔符
    const pinyinSeparator = ',';
    if (isEmpty) return '';
    StringBuffer sb = StringBuffer();
    StringBuffer temp = StringBuffer();
    for (int i = 0, len = length; i < len; i++) {
      String c = this[i];
      if (ChineseHelper.isChinese(c)) {
        int j = i + 1;
        temp.write(c);
        while (j < len && (ChineseHelper.isChinese(this[j]))) {
          temp.write(this[j]);
          j++;
        }
        String pinyin = PinyinHelper.getPinyinE(temp.toString(),
            separator: pinyinSeparator);
        List<String> pinyinArray = pinyin.split(pinyinSeparator);
        for (var v in pinyinArray) {
          sb.write(v[0]);
          i++;
        }
        i--;
        temp.clear();
      } else {
        sb.write(c);
      }
    }
    return sb.toString();
  }

  /// 获取字符串拼音
  String get pinyin => PinyinHelper.getPinyinE(
        this,
        separator: '',
      );

  /// 获取字符串拼音和拼音与原位置的对应
  PinyinAndMap get pinyinAndPosMap {
    if (isEmpty) {
      return PinyinAndMap(
        pinyin: '',
        posMap: null,
        reverseMap: null,
      );
    }
    final map = <int, PinyinStartAndLen>{};
    final reverseMap = <int, int>{};
    String separator = '';
    String defPinyin = ' ';
    PinyinFormat format = PinyinFormat.WITHOUT_TONE;

    StringBuffer sb = StringBuffer();
    String str = ChineseHelper.convertToSimplifiedChinese(this);
    int strLen = str.length;
    int i = 0;
    while (i < strLen) {
      String subStr = str.substring(i);
      MultiPinyin? node =
          PinyinHelper.convertToMultiPinyin(subStr, separator, format);
      if (node == null) {
        String char = str[i];
        reverseMap[i] = sb.length;
        if (ChineseHelper.isChinese(char)) {
          List<String> pinyinArray =
              PinyinHelper.convertToPinyinArray(char, format);
          if (pinyinArray.isNotEmpty) {
            map[sb.length] =
                PinyinStartAndLen(startPos: i, len: pinyinArray[0].length);
            sb.write(pinyinArray[0]);
          } else {
            sb.write(defPinyin);
          }
        } else {
          sb.write(char);
        }
        if (i < strLen) {
          sb.write(separator);
        }
        i++;
      } else {
        sb.write(node.pinyin);
        i += node.word!.length;
      }
    }
    String res = sb.toString();

    return PinyinAndMap(
      pinyin: ((res.endsWith(separator) && separator != '')
          ? res.substring(0, res.length - 1)
          : res),
      posMap: map.isEmpty ? null : map,
      reverseMap: reverseMap.isEmpty ? null : reverseMap,
    );
  }

  /// 获取拼音
  String get pinyinFirstLetter {
    if (startsWith('调度')) {
      return 'D';
    }
    return isEmpty
        ? ''
        : PinyinHelper.getFirstWordPinyin(this)[0].toUpperCase();
  }

  /// 判断为空或者为空字符串
  bool get isBlank {
    if (trim() == '') {
      return true;
    }
    return false;
  }

  /// 首字母小写
  String get firstToLower =>
      isNotEmpty ? replaceFirst(this[0], this[0].toLowerCase()) : '';

  /// 首字母大写
  String get firstToUpper =>
      isNotEmpty ? replaceFirst(this[0], this[0].toUpperCase()) : '';

  /// 下划线转驼峰
  String get underLineToCamel {
    int pos;
    String res = this;
    while ((pos = res.indexOf('_')) != -1) {
      res = res.replaceRange(
        pos,
        pos + 2,
        res[pos + 1].toUpperCase().toString(),
      );
    }
    return res;
  }

  /// 驼峰转下划线
  String get camelToUnderLine {
    String res = this;
    for (int i = 1; i < res.length; i++) {
      if (res[i].compareTo('a') < 0) {
        // 若为大写字母
        res = res.replaceRange(i, i + 1, '_${res[i].toLowerCase()}');
      }
    }
    return res;
  }

  String get javaType {
    final map = {
      'datetime': 'Date',
      'time': 'Date',
      'date': 'Date',
      'timestamp': 'Date',
      'tinyint': 'Integer',
      'smallint': 'Integer',
      'mediumint': 'Integer',
      'int': 'Integer',
      'number': 'Integer',
      'integer': 'Integer',
      'bit': 'Integer',
      'bigint': 'Long',
      'float': 'Double',
      'double': 'Double',
      'real': 'Double',
      'decimal': 'BigDecimal',
    };
    return map[this] ?? 'String';
  }

  String get dartType {
    final map = {
      'datetime': 'DateTime',
      'time': 'DateTime',
      'date': 'DateTime',
      'timestamp': 'DateTime',
      'tinyint': 'int',
      'smallint': 'int',
      'mediumint': 'int',
      'int': 'int',
      'number': 'int',
      'integer': 'int',
      'bit': 'int',
      'bigint': 'int',
      'float': 'double',
      'double': 'double',
      'real': 'double',
      'decimal': 'double',
    };
    return map[this] ?? 'String';
  }

  String get goType {
    final map = {
      'datetime': 'int64',
      'time': 'int64',
      'date': 'int64',
      'timestamp': 'int64',
      'tinyint': 'int',
      'smallint': 'int',
      'mediumint': 'int',
      'int': 'int',
      'number': 'int',
      'integer': 'int',
      'bit': 'int',
      'bigint': 'int',
      'float': 'double',
      'double': 'double',
      'real': 'double',
      'decimal': 'double',
    };
    return map[this] ?? 'string';
  }

  String get sqliteJavaType {
    final map = {
      'integer': 'Integer',
      'real': 'Double',
    };
    return map[this] ?? 'String';
  }

  String get sqliteDartType {
    final map = {
      'integer': 'int',
      'real': 'double',
    };
    return map[this] ?? 'String';
  }

  String get sqliteGoType {
    final map = {
      'integer': 'int',
      'real': 'double',
    };
    return map[this] ?? 'string';
  }

  String get convertFileSeparator => replaceAll('\\', '/');
}

/// 拼音和对应位置
class PinyinAndMap {
  final String pinyin;

  /// 从拼音映射到原字符串的 map
  final Map<int, PinyinStartAndLen>? posMap;

  /// 从原字符串映射到拼音的 map
  final Map<int, int>? reverseMap;

  PinyinAndMap({
    required this.pinyin,
    required this.posMap,
    required this.reverseMap,
  });
}

class PinyinStartAndLen {
  /// 开始位置
  final int startPos;

  /// 拼音长度
  final int len;

  PinyinStartAndLen({
    required this.startPos,
    required this.len,
  });

  @override
  String toString() {
    return '[$startPos, $len]';
  }
}
