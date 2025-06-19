import '../util/date_utils.dart';

/// 图片记录
class PicRecord {
  /// ID
  final String? id;

  /// 图片名称
  final String name;

  /// 图像
  final String image;

  /// 创建时间
  int? createdAt;

  /// 更新时间
  int? updatedAt;

  PicRecord({
    this.id,
    required this.name,
    required this.image,
    int? createdAt,
    int? updatedAt,
  }) {
    final cur = currentMillis();
    this.createdAt = createdAt ?? cur;
    this.updatedAt = updatedAt ?? cur;
  }

  factory PicRecord.fromJson(Map<String, dynamic> json) => PicRecord(
        id: json['id'] as String?,
        name: json['name'] as String,
        image: json['image'] as String,
        createdAt: json['created_at'] as int?,
        updatedAt: json['updated_at'] as int?,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'image': image,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  @override
  String toString() =>
      'PicRecord{id: $id, name: $name, image: $image, createdAt: $createdAt, updatedAt: $updatedAt}';
}
