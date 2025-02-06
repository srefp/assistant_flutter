import 'package:flutter/material.dart';

/// 字体
String get fontFamily => 'MiSans';

class WinText extends StatelessWidget {
  const WinText(
    this.data, {
    super.key,
    this.selectable = false,
    this.textAlign = TextAlign.start,
    this.style,
  });

  final String data;
  final bool selectable;
  final TextAlign textAlign;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    String font = fontFamily;
    if (style?.fontFamily != null) {
      font = style?.fontFamily ?? fontFamily;
    }
    TextStyle textStyle = style?.copyWith(fontFamily: font) ??
        TextStyle(
          fontFamily: font,
        );
    return selectable
        ? SelectableText(
            data,
            style: textStyle,
            textAlign: textAlign,
          )
        : Text(
            data,
            style: textStyle,
            textAlign: textAlign,
          );
  }
}
