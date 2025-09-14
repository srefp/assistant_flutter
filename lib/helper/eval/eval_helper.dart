// main.dart
import 'dart:io';
import 'package:dart_eval/dart_eval.dart';

Future<void> writeDataToFile(String filePath, String data) async {
  final file = File(filePath);
  await file.writeAsString(data, mode: FileMode.write);
}

void main() async {
  // 现在可以在 eval 中调用它
  const script = r'''
  void main() async {
    await writeDataToFile('D:/abc.txt', '123456');
  }
  ''';

  try {
    print(eval(script, function: 'main'));
    print('脚本执行完成，文件已写入。');
  } catch (e) {
    print('执行失败: $e');
  }
}