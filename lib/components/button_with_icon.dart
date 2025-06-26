import 'package:assistant/components/win_text.dart';
import 'package:fluent_ui/fluent_ui.dart';

class ButtonWithIcon extends StatelessWidget {
  final IconData? icon;
  final String text;
  final VoidCallback? onPressed;
  final ButtonStyle? style;

  const ButtonWithIcon({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Button(
      onPressed: onPressed,
      style: style,
      child: Row(
        children: [
          Icon(icon, size: 18),
          SizedBox(width: 6),
          WinText(text),
        ],
      ),
    );
  }
}
