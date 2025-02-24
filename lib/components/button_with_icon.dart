import 'package:assistant/components/win_text.dart';
import 'package:fluent_ui/fluent_ui.dart';

class ButtonWithIcon extends StatelessWidget {
  final IconData? icon;
  final String text;
  final VoidCallback? onPressed;

  const ButtonWithIcon({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Button(
      onPressed: onPressed,
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
