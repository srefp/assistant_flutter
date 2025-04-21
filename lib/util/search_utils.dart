import 'dart:math';

import 'package:assistant/extensions/pinyin_pos_map_extension.dart';

import '../extensions/string_extension.dart';

/// 小写匹配、拼音首字母匹配、拼音匹配
List<int> multiMatch({
  required String textLower,
  required String pinyinShort,
  required PinyinAndMap pinyinAndPosMap,
  required String searchValue,
  required int start,
}) {
  int lowerPos = textLower.indexOf(searchValue, start);
  int pinyinShortPos = pinyinShort.indexOf(searchValue, start);
  int pinyinPos = -1;
  if (pinyinAndPosMap.reverseMap?[start] != null) {
    pinyinPos = pinyinAndPosMap.pinyin
        .indexOf(searchValue, pinyinAndPosMap.reverseMap![start]!);
  }

  final hasPositionList =
      [lowerPos, pinyinShortPos, pinyinPos].where((e) => e != -1).toList();
  // 如果全部搜索不到，返回 -1
  if (hasPositionList.isEmpty) {
    return [-1, searchValue.length];
  }
  // 从搜索到的位置中选择一个最小位置返回
  int minPos = hasPositionList.first;
  for (final pos in hasPositionList) {
    minPos = min(minPos, pos);
  }
  // 如果是拼音匹配到了字符串
  if (pinyinPos == minPos) {
    // 如果匹配的第一个位置满足：
    // 小写字符串在该位置上的字符和拼音字符串在该位置上的字符相同
    // 则返回的匹配位置就是字符串匹配的第一个位置
    if (textLower.length > pinyinPos &&
        textLower[pinyinPos] == pinyinAndPosMap.pinyin[pinyinPos]) {
      return [
        pinyinPos,
        pinyinAndPosMap.posMap?.pinyinMatchLen(pinyinPos, searchValue.length) ??
            searchValue.length,
      ];
    }
    // 如果匹配的不是拼音首字母，则返回小写匹配
    if (pinyinAndPosMap.posMap?[pinyinPos] == null) {
      return [lowerPos, searchValue.length];
    }
    // 返回拼音匹配
    return [
      pinyinAndPosMap.posMap?[pinyinPos]?.startPos ?? -1,
      pinyinAndPosMap.posMap?.pinyinMatchLen(pinyinPos, searchValue.length) ??
          searchValue.length,
    ];
  }
  return [minPos, searchValue.length];
}
