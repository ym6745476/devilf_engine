import 'dart:ui';
import 'package:devilf_engine/core/df_circle.dart';
import 'package:devilf_engine/core/df_position.dart';
import 'package:devilf_engine/sprite/df_sprite.dart';
import 'package:flutter/material.dart';
import 'df_camera.dart';
import 'df_sprite_widget.dart';

/// 游戏控件
class DFGameWidget extends StatelessWidget {
  /// 尺寸
  final Size size;

  /// 摄像机
  final DFCamera camera;

  /// 精灵控件
  late DFSpriteWidget spriteWidget;

  /// 点击抬起
  Function(DFSprite sprite)? onTap;

  /// 当前帧数
  double fps = 60;

  /// 创建游戏控件
  DFGameWidget({
    this.size = const Size(100, 100),
    required this.camera,
    this.onTap,
  }) {
    this.spriteWidget = DFSpriteWidget(
        camera: this.camera,
        onTimingsCallback: (List<FrameTiming> timings) {
          this.fps = 1 / (timings[0].totalSpan.inMilliseconds / 1000.0);
        });
  }

  /// 增加精灵 增加进来精灵才能被绘制
  void addChild(DFSprite? sprite) {
    this.spriteWidget.addChild(sprite);
  }

  /// 插入精灵 增加进来精灵才能被绘制
  void insertChild(int index, DFSprite? sprite) {
    this.spriteWidget.insertChild(index, sprite);
  }

  /// 增加精灵 增加进来精灵才能被绘制
  void addChildren(List<DFSprite> sprites) {
    this.spriteWidget.addChildren(sprites);
  }

  /// 插入精灵 增加进来精灵才能被绘制
  void insertChildren(int index, List<DFSprite> sprites) {
    this.spriteWidget.insertChildren(index, sprites);
  }

  /// 删除精灵
  void removeChild(DFSprite sprite) {
    this.spriteWidget.removeChild(sprite);
  }

  /// 屏幕坐标转换为世界坐标
  DFPosition screenToWorldPosition(Offset localPosition){
    if(this.camera.sprite != null){
      /// 屏幕上的坐标转换为实际坐标 计算出屏幕的0点的实际地图坐标
      double moveX = this.camera.sprite!.position.x - this.camera.rect.width / 2;
      double moveY = this.camera.sprite!.position.y - this.camera.rect.height / 2;
      return DFPosition(localPosition.dx + moveX, localPosition.dy + moveY);
    }else{
      return DFPosition(localPosition.dx, localPosition.dy);
    }
  }

  /// 点击监听
  void onTapUp(TapUpDetails details) {
    print("监听到点击：" + details.localPosition.toString());
    for (int i = this.spriteWidget.children.length - 1; i >= 0; i--) {
      DFSprite sprite = this.spriteWidget.children[i];
      /// 屏幕坐标转换为世界坐标
      DFPosition center = screenToWorldPosition(details.localPosition);
      if (sprite.getCollisionShape().overlaps(DFCircle(center, 5))) {
        if (this.onTap != null) {
          this.onTap!(sprite);
        }
        return;
      }
    }
  }

  /// 控件布局
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        width: this.size.width,
        height: this.size.height,
        child: spriteWidget,
      ),
      onTapUp: this.onTapUp,
    );
  }
}
