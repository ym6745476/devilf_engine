import 'dart:ui';

/// 位置
class DFPosition {
  /// x坐标
  double x;

  /// y坐标
  double y;

  /// 创建坐标
  DFPosition(this.x, this.y);

  /// 转换为Offset
  Offset toOffset() => Offset(x, y);

  @override
  bool operator == (Object other) {
    if (other is DFPosition) {
      return x == other.x && y == other.y;
    }
    return false;
  }

  /// 转换为字符串
  @override
  String toString() {
    return "x:" + x.toString() + ",y:" + y.toString();
  }
}

/// 瓦片位置
class DFTilePosition {
  int x;
  int y;

  DFTilePosition(this.x, this.y);

  @override
  bool operator ==(Object other) {
    if (other is DFTilePosition) {
      return x == other.x && y == other.y;
    }
    return false;
  }

  @override
  String toString() {
    return "x:" + x.toString() + ",y:" + y.toString();
  }
}

/// 方位
enum DFGravity {
  /// 左
  left,

  /// 上
  top,

  /// 右
  right,

  /// 下
  bottom,

  /// 中
  center
}
