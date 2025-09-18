import 'package:fluent_ui/fluent_ui.dart';

import '../text/win_text.dart';

class TipIconButton extends StatelessWidget {
  final String tip;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;

  const TipIconButton({
    super.key,
    required this.tip,
    required this.icon,
    this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tip,
      style: TooltipThemeData(textStyle: TextStyle(fontFamily: fontFamily)),
      child: IconButton(
        icon: Icon(
          icon,
          size: 16,
          color: color,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
