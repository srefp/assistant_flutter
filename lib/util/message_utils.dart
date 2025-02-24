import 'package:bot_toast/bot_toast.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../components/win_text.dart';

/// 顶部或者底部消息框
void snack(
  String title,
  String message, {
  SnackPosition snackPosition = SnackPosition.TOP,
}) {
  Get.snackbar(
    '',
    '',
    titleText: WinText(title),
    messageText: WinText(message),
    snackPosition: snackPosition,
  );
}

/// 中下位置的消息
void toast(
  String msg, {
  MsgDuration duration = MsgDuration.short,
}) {
  if (GetPlatform.isDesktop) {
    BotToast.showText(
      text: msg,
      duration: duration == MsgDuration.short
          ? const Duration(seconds: 2)
          : const Duration(seconds: 5),
    );
  } else if (GetPlatform.isAndroid) {
    Fluttertoast.showToast(
      msg: msg,
      gravity: ToastGravity.CENTER,
      toastLength: duration == MsgDuration.short
          ? Toast.LENGTH_SHORT
          : Toast.LENGTH_LONG,
    );
  }
}

enum MsgDuration {
  // 5s
  long,
  // Android 1s, Windows 2s
  short,
}
