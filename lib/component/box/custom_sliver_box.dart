import 'package:fluent_ui/fluent_ui.dart';

class CustomSliverBox extends StatelessWidget {
  final Widget child;

  const CustomSliverBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverToBoxAdapter(
        child: child,
      ),
    );
  }
}
