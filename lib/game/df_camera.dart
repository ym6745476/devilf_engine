import 'package:devilf_engine/core/df_offset.dart';
import 'package:devilf_engine/core/df_rect.dart';
import 'package:devilf_engine/sprite/df_sprite.dart';

/// 摄像机
class DFCamera {
  /// 跟踪目标
  DFSprite? sprite;

  /// 视窗区域
  final DFRect rect;

  /// 限制X
  DFOffset? limit;

  /// 创建矩形
  DFCamera({required this.rect});

  /// 设置跟随目标
  void lookAt(DFSprite sprite) {
    this.sprite = sprite;
  }

  /// 设置限制
  void setLimit(DFOffset limit) {
    this.limit = limit;
    print("Camera setLimit:" + limit.toString());
  }
}
