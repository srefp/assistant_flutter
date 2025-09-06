import 'dart:convert';

import 'package:assistant/helper/cv/cv.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:opencv_dart/opencv.dart' as cv;

import '../../../component/text/win_text.dart';
import '../../../helper/auto_gui/key_mouse_util.dart';
import '../../../helper/auto_gui/system_control.dart';
import '../../../helper/screen/screen_manager.dart';
import '../../../helper/win32/toast.dart';
import '../../config/app_config.dart';

class Test extends StatelessWidget {
  const Test({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(20),
      children: [
        WinText(
          '测试',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            SizedBox(
              width: 100,
              child: Button(
                child: WinText('弹出消息框'),
                onPressed: () {
                  KeyMouseUtil.showCoordinate();
                },
              ),
            ),
            SizedBox(width: 16),
            SizedBox(
              width: 120,
              child: Button(
                child: WinText('获取窗口句柄'),
                onPressed: () {
                  ScreenManager.instance.refreshWindowHandle();
                  showToast('句柄： ${ScreenManager.instance.hWnd}');
                },
              ),
            ),
            SizedBox(width: 16),
            SizedBox(
              width: 120,
              child: Button(
                child: WinText('截图'),
                onPressed: () {
                  var rect = ScreenRect(0, 0, 6000, 3000);
                  var data = captureAsBgra(rect);
                  if (data == null) {
                    return;
                  }
                  saveScreenshot(data, rect.width, rect.height,
                      'D:\\demo\\screenshot.png');
                },
              ),
            ),
            SizedBox(width: 16),
            SizedBox(
              width: 120,
              child: Button(
                child: WinText('截图分析'),
                onPressed: () {
                  final rect = ScreenRect(10, 10, 12, 12);

                  // 截图
                  final image = captureAsBgra(rect);

                  debugPrint('1. 截图:');
                  debugPrint(image.toString());

                  // 转换为mat
                  final mat = uint8ListToMat(image!, rect.width, rect.height);

                  debugPrint('2. 转换为mat:');
                  debugPrint(mat.toString());

                  // 灰度图
                  final gray = cv.cvtColor(mat, cv.COLOR_BGR2GRAY);

                  debugPrint('3. 灰度图:');
                  debugPrint(gray.toString());

                  final base64 = base64Encode(image);

                  debugPrint('4. 转换为base64:');
                  debugPrint(base64);

                  // 将base64字符串解码为Uint8List
                  final bytes = base64Decode(base64);

                  debugPrint('5. 转换为uint8List:');
                  debugPrint(bytes.toString());

                  cv.Mat colorMat = cv.imdecode(bytes, cv.IMREAD_COLOR);

                  debugPrint('6. 转换为mat:');
                  debugPrint(colorMat.toString());
                },
              ),
            ),
            SizedBox(width: 16),
            SizedBox(
              width: 120,
              child: Button(child: WinText('显示许可协议'), onPressed: () {
                AppConfig.to
                    .save(AppConfig.keyEulaNotificationDisabled, false);
              }),
            ),
          ],
        ),
      ],
    );
  }
}
