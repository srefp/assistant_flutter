import 'dart:convert';

import '../util/date_utils.dart';
import 'package:opencv_dart/opencv.dart' as cv;

/// 图片记录
class PicRecord {
  /// ID
  int? id;

  /// 图片名称
  String picName;

  /// 图像
  String image;

  /// 图片
  cv.Mat? mat;

  /// 创建时间
  int? createdOn;

  /// 更新时间
  int? updatedOn;

  PicRecord({
    this.id,
    required this.picName,
    required this.image,
    int? createdOn,
    int? updatedOn,
  }) {
    final cur = currentMillis();
    this.createdOn = createdOn ?? cur;
    this.updatedOn = updatedOn ?? cur;
  }

  void setMat() {
    // 将base64字符串解码为Uint8List
    final bytes = base64Decode(image);
    // 使用OpenCV解码图片
    mat = cv.imdecode(bytes, cv.IMREAD_GRAYSCALE);
  }

  factory PicRecord.fromJson(Map<String, dynamic> json) => PicRecord(
        id: json['id'] as int?,
        picName: json['picName'] as String,
        image: json['image'] as String,
        createdOn: json['createdOn'] as int?,
        updatedOn: json['updatedOn'] as int?,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'picName': picName,
        'image': image,
        'createdOn': createdOn,
        'updatedOn': updatedOn,
      };

  @override
  String toString() =>
      'PicRecord{id: $id, picName: $picName, image: $image, createdOn: $createdOn, updatedOn: $updatedOn}';
}
