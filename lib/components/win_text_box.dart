import 'package:assistant/components/win_text.dart';
import 'package:fluent_ui/fluent_ui.dart';

/// 字体
class WinTextBox extends StatelessWidget {
  const WinTextBox({
    super.key,
    this.textAlign = TextAlign.start,
    this.style,
    this.controller,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.suffix,
    this.placeholder,
    this.focusNode,
  });

  final TextAlign textAlign;
  final TextStyle? style;
  final TextEditingController? controller;
  final GestureTapCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffix;
  final String? placeholder;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final String font = style?.fontFamily ?? fontFamily;
    final TextStyle textStyle =
        style?.copyWith(fontFamily: font) ?? TextStyle(fontFamily: font);
    return TextBox(
      controller: controller,
      style: textStyle,
      textAlign: textAlign,
      onTap: onTap,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      suffix: suffix,
      placeholder: placeholder,
      focusNode: focusNode,
    );
  }
}
