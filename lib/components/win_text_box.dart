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
    this.showCursor = true,
    this.enableInteractiveSelection = true,
    this.minLines,
    this.maxLines = 1,
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
  final bool showCursor;
  final bool enableInteractiveSelection;
  final int? minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final String font = style?.fontFamily ?? fontFamily;
    final TextStyle textStyle =
        style?.copyWith(fontFamily: font) ?? TextStyle(fontFamily: font);
    return TextBox(
      minLines: minLines,
      maxLines: maxLines,
      controller: controller,
      style: textStyle,
      textAlign: textAlign,
      onTap: onTap,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      suffix: suffix,
      placeholder: placeholder,
      focusNode: focusNode,
      showCursor: showCursor,
      enableInteractiveSelection: enableInteractiveSelection,
    );
  }
}
