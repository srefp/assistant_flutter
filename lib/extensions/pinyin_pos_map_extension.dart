import 'dart:math';

import 'string_extension.dart';

extension PinyinPosMapExtension on Map<int, PinyinStartAndLen> {
  /// 根据拼音开始匹配的位置和拼音的长度确定汉字的长度
  int pinyinMatchLen(int pinyinPos, int pinyinLen) {
    // 当前位置
    int curPos = pinyinPos;
    // 高亮的字符串长度
    int lightLen = pinyinLen;
    int end = pinyinPos + pinyinLen;
    for (; curPos < end; curPos++) {
      if (this[curPos] != null) {
        int len = this[curPos]!.len;
        lightLen -= min(end - curPos - 1, len - 1);
        curPos += (len - 1);
      }
    }
    return lightLen;
  }
}
