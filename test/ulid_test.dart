import 'package:ulid/ulid.dart';

main() {
  // 生成一个新的 ULID
  var ulid = Ulid();
  // 打印 ULID
  print('ULID: ${ulid.toString()}');
  print('ULID: ${ulid.toUuid()}');
}
