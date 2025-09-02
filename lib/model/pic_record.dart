import 'package:assistant/util/cv/cv_helper.dart';
import 'package:opencv_dart/opencv.dart' as cv;

import '../cv/cv.dart';
import '../util/date_utils.dart';

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
    final bytes = pngToBgra(stringToPngList(image));
    cv.Mat mat = uint8ListToMat(bytes, width, height);
    this.mat = cv.cvtColor(mat, cv.COLOR_BGR2GRAY);
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
