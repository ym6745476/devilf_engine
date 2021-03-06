import 'dart:ui';
import 'df_circle.dart';
import 'df_position.dart';
import 'df_shape.dart';

/// 矩形
class DFRect extends DFShape {
  /// 左坐标
  double left = 0;

  /// 上坐标
  double top = 0;

  /// 右坐标
  double right = 0;

  /// 下坐标
  double bottom = 0;

  /// 宽度
  final double width;

  /// 高度
  final double height;

  /// 创建矩形
  DFRect(this.left, this.top, this.width, this.height) {
    this.right = this.left + this.width;
    this.bottom = this.top + this.height;
  }

  /// 创建矩形
  DFRect.fromCenter({ required DFPosition center, required this.width, required this.height}) {
    this.left = center.x - width / 2;
    this.top = center.y - height / 2;
    this.right = this.left + this.width;
    this.bottom = this.top + this.height;
  }

  /// 转换为Rect
  Rect toRect() => Rect.fromLTWH(this.left, this.top, width, height);

  /// 中心坐标
  DFPosition center() {
    return DFPosition(this.left + this.width / 2, this.top + this.height / 2);
  }

  /// 是否重叠
  @override
  bool overlaps(DFShape other) {
    if (other is DFRect) {
      return rectToRect(other);
    } else if (other is DFCircle) {
      return other.circleToRect(this);
    }
    return false;
  }

  /// 矩形碰撞
  bool rectToRect(DFRect other) {
    if (right <= other.left || other.right <= left) return false;
    if (bottom <= other.top || other.bottom <= top) return false;
    return true;
  }

  /// 转换为字符串
  @override
  String toString() {
    return "left:" +
        left.toString() +
        ",top:" +
        top.toString() +
        ",width:" +
        width.toString() +
        ",height:" +
        height.toString();
  }
}
