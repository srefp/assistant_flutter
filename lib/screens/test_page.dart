import 'dart:convert';

import 'package:assistant/auto_gui/key_mouse_util.dart';
import 'package:assistant/cv/cv.dart';
import 'package:assistant/manager/screen_manager.dart';
import 'package:assistant/win32/toast.dart';
import 'package:fluent_ui/fluent_ui.dart';

import '../auto_gui/system_control.dart';
import '../components/win_text.dart';
import 'package:opencv_dart/opencv.dart' as cv;

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
                  saveScreenshot(data, rect.width, rect.height, 'D:\\demo\\screenshot.png');
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

                  print('1. 截图:');
                  print(image);

                  // 转换为mat
                  final mat = uint8ListToMat(image!, rect.width, rect.height);

                  print('2. 转换为mat:');
                  print(mat);

                  // 灰度图
                  final gray = cv.cvtColor(mat, cv.COLOR_BGR2GRAY);

                  print('3. 灰度图:');
                  print(gray);

                  // final encodedBytes = cv.imencode('.png', mat);

                  // print('4. encodedBytes:');
                  // print(encodedBytes);

                  final base64 = base64Encode(image);

                  print('5. 转换为base64:');
                  print(base64);

                  // 将base64字符串解码为Uint8List
                  final bytes = base64Decode(base64);

                  print('6. 转换为uint8List:');
                  print(bytes);

                  cv.Mat colorMat = cv.imdecode(bytes, cv.IMREAD_COLOR);

                  print('7. 转换为mat:');
                  print(colorMat);

                  // cv.Mat mat = uint8ListToMat(bytes, width, height);
                  // mat = cv.cvtColor(mat, cv.COLOR_BGR2GRAY);
                  // // 使用OpenCV解码图片
                  // mat = cv.imdecode(bytes, cv.IMREAD_GRAYSCALE);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
