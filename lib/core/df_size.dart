/// 尺寸
class DFSize {
  /// 宽度
  final double width;

  /// 高度
  final double height;

  /// 创建尺寸
  const DFSize(this.width, this.height);

  /// 转换为字符串
  @override
  String toString() {
    return "width:" + width.toString() + ",height:" + height.toString();
  }
}
