import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

void showOverlay(BuildContext context) async {
  if (await FlutterOverlayWindow.isActive()) return;

  debugPrint('显示Overlay');
  await FlutterOverlayWindow.showOverlay(
    enableDrag: true,
    overlayTitle: "X-SLAYER",
    overlayContent: 'Overlay Enabled',
    flag: OverlayFlag.defaultFlag,
    visibility: NotificationVisibility.visibilityPublic,
    positionGravity: PositionGravity.auto,
    height: (MediaQuery.of(context).size.height * 0.6).toInt(),
    width: WindowSize.matchParent,
    startPosition: const OverlayPosition(0, -259),
  );
  debugPrint('Overlay显示成功');
}

Future<void> getPermission() async {
  /// check if overlay permission is granted
  final bool status = await FlutterOverlayWindow.isPermissionGranted();

  if (!status) {
    await FlutterOverlayWindow.requestPermission();
  }
}
