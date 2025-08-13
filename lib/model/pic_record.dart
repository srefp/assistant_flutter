import 'dart:convert';

import '../cv/cv.dart';
import '../util/date_utils.dart';
import 'package:opencv_dart/opencv.dart' as cv;

/// 图片记录
class PicRecord {
  /// ID
  int? id;

  /// 图片名称
  String picName;

  /// 图片key
  String key;

  /// 备注
  String comment;

  /// 图像
  String image;

  /// 宽度
  int width;

  /// 高度
  int height;

  /// 图片
  cv.Mat? mat;

  /// 创建时间
  int? createdOn;

  /// 更新时间
  int? updatedOn;

  PicRecord({
    this.id,
    required this.picName,
    required this.key,
    required this.comment,
    required this.image,
    required this.width,
    required this.height,
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
    cv.Mat mat = cv.imdecode(bytes, cv.IMREAD_COLOR);
    // cv.Mat mat = uint8ListToMat(bytes, width, height);
    mat = cv.cvtColor(mat, cv.COLOR_BGR2GRAY);
    // 使用OpenCV解码图片
    mat = cv.imdecode(bytes, cv.IMREAD_GRAYSCALE);
  }

  factory PicRecord.fromJson(Map<String, dynamic> json) => PicRecord(
        id: json['id'] as int?,
        picName: json['picName'] as String,
        key: json['key'] as String,
        comment: json['comment'] as String,
        image: json['image'] as String,
        width: json['width'] as int,
        height: json['height'] as int,
        createdOn: json['createdOn'] as int?,
        updatedOn: json['updatedOn'] as int?,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'picName': picName,
        'key': key,
        'comment': comment,
        'image': image,
        'width': width,
        'height': height,
        'createdOn': createdOn,
        'updatedOn': updatedOn,
      };

  @override
  String toString() =>
      'PicRecord{id: $id, picName: $picName, key: $key, comment: $comment, image: $image, width: $width, height: $height, createdOn: $createdOn, updatedOn: $updatedOn}';
}
