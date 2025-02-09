import 'dart:convert';

import 'package:dartssh2/dartssh2.dart';

import '../util/asset_loader.dart';

Future<void> executeSSH(String shellScript) async {

  final key = await readAsset('assets/ssh_key/Microstar.AWS.3430.ppk');

  print(key);

  print('开始连接');

  final client = SSHClient(
    await SSHSocket.connect('ec2-3-104-152-22.ap-southeast-2.compute.amazonaws.com', 22),
    username: 'ec2-user',
    identities: SSHKeyPair.fromPem(key),
  );

  print('连接成功');

  final res = await client.run(shellScript);
  print(utf8.decode(res));

  final uptime = await client.run('uptime');
  print(utf8.decode(uptime));

  client.close();
}
