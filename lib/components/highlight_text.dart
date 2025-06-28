import 'package:assistant/components/win_text.dart';
import 'package:flutter/material.dart';

import '../extensions/string_extension.dart';
import '../util/search_utils.dart';

/// 高亮Text
class HighlightText extends StatelessWidget {
  /// 要显示的内容
  final String text;

  /// 小写内容
  final String textLower;

  /// 拼音位置对应
  late final PinyinAndMap pinyinAndPosMap;

  /// 内容拼音的首字母
  late final String pinyinShort;

  /// 要显示的内容中，需要高亮显示的文字(默认为空字符串，即不高亮显示文本)
  final String lightText;

  /// 要显示的内容的文本风格
  final TextStyle? style;

  /// 要显示的内容中，需要高亮显示的文字的文本风格
  final TextStyle? lightStyle;

  /// 默认普通文本的样式
  final TextStyle _defaultTextStyle = TextStyle(
    fontSize: 14,
    fontFamily: fontFamily,
  );

  /// 默认高亮文本的样式
  final TextStyle _defaultLightStyle = TextStyle(
    fontSize: 14,
    color: Colors.orangeAccent,
    fontFamily: fontFamily,
  );

  HighlightText(
    this.text, {
    super.key,
    this.lightText = '',
    this.style,
  })  : textLower = text.toLowerCase(),
        lightStyle = style?.copyWith(
          color: Colors.orangeAccent,
        ) {
    pinyinShort = textLower.pinyinShort;
    pinyinAndPosMap = textLower.pinyinAndPosMap;
  }

  @override
  Widget build(BuildContext context) {
    // 如果没有需要高亮显示的内容
    if (lightText.isEmpty) {
      return Text(
        text.replaceAll('', '\u200B'),
        style: style ?? _defaultTextStyle,
      );
    }
    // 如果有需要高亮显示的内容
    return _lightView();
  }

  /// 返回根据小写字符串、拼音、拼音首字母获取的 最小匹配位置 和 高亮长度
  /// 格式：[minPos, lightLen]
  List<int> minIndexAndLightLenOf(String searchValue, int start) {
    return multiMatch(
      textLower: textLower,
      pinyinShort: pinyinShort,
      pinyinAndPosMap: pinyinAndPosMap,
      searchValue: searchValue,
      start: start,
    );
  }

  /// 需要高亮显示的内容
  Widget _lightView() {
    // 都转换成小写再进行比较
    final lightTextLower = lightText.toLowerCase();

    List<TextSpan> spans = [];
    // 当前要截取字符串的起始位置
    int start = 0;
    // end 表示要高亮显示的文本出现在当前字符串中的索引
    int end;
    List<int> minIndexAndLightLen;
    // 如果有符合的高亮文字
    while ((end = (minIndexAndLightLen =
            minIndexAndLightLenOf(lightTextLower, start))[0]) !=
        -1) {
      int lightLen = minIndexAndLightLen[1];
      // 获取符合的高亮文字再text中对应的原始文字
      final originalTextPart = text.substring(end, end + lightLen);
      // 第一步：添加正常显示的文本
      spans.add(TextSpan(
          text: text.substring(start, end),
          style: style ?? _defaultTextStyle));
      // 第二步：添加高亮显示的文本
      spans.add(TextSpan(
          text: originalTextPart, style: lightStyle ?? _defaultLightStyle));
      // 设置下一段要截取的开始位置
      start = end + lightLen;
    }
    // 如果没有要高亮显示的，则start=0，也就是返回了传进来的text
    // 如果有要高亮显示的，则start=最后一个高亮显示文本的索引，然后截取到text的末尾
    spans.add(
      TextSpan(
          text: text.substring(start, text.length),
          style: style ?? _defaultTextStyle),
    );

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}
