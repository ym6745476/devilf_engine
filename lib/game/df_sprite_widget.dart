import 'dart:ui';
import 'package:devilf_engine/sprite/df_sprite.dart';
import 'package:flutter/material.dart';
import 'df_camera.dart';
import 'df_sprite_render_box.dart';

/// 精灵渲染控件（游戏主循环）
/// 继承LeafRenderObjectWidget实现RenderBox可以使用canvas实现Widget
class DFSpriteWidget extends LeafRenderObjectWidget {
  /// 摄像机
  final DFCamera camera;

  /// 游戏里的所有精灵
  final List<DFSprite> children = [];

  /// 时间回调
  final Function(List<FrameTiming> timings) onTimingsCallback;

  /// 创建游戏控件
  DFSpriteWidget({required this.camera, required this.onTimingsCallback});

  /// 增加精灵 增加进来精灵才能被绘制
  void addChild(DFSprite? sprite) {
    if (sprite != null) {
      children.add(sprite);
    }
  }

  /// 插入精灵 增加进来精灵才能被绘制
  void insertChild(int index, DFSprite? sprite) {
    if (sprite != null) {
      children.insert(index, sprite);
    }
  }

  /// 增加精灵 增加进来精灵才能被绘制
  void addChildren(List<DFSprite> sprites) {
    children.addAll(sprites);
  }

  /// 插入精灵 增加进来精灵才能被绘制
  void insertChildren(int index, List<DFSprite> sprites) {
    sprites.forEach((element) {
      children.insert(index, element);
    });
  }

  /// 删除精灵
  void removeChild(DFSprite sprite) {
    /// 不能直接remove会并发修改错误
    sprite.visible = false;
    sprite.recyclable = true;
  }

  /// 创建GameRenderBox
  @override
  RenderBox createRenderObject(BuildContext context) {
    return DFSpriteRenderBox(context, this);
  }

  /// 设置Game到GameRenderBox
  @override
  void updateRenderObject(BuildContext context, DFSpriteRenderBox renderObject) {
    renderObject.spriteWidget = this;
  }

  /// 更新界面
  void update(double dt) {
    children.forEach((sprite) {
      if (!sprite.visible && sprite.recyclable) {
        /// 将要回收的精灵不更新
      } else {
        sprite.update(dt);
      }
    });

    /// 清除不可见的并且需要回收的的精灵
    children.removeWhere((sprite) => (sprite.visible == false && sprite.recyclable));
  }

  /// 绘制界面
  void render(Canvas canvas) {
    canvas.save();

    /// 需要移动的位置
    double moveX = 0;
    double moveY = 0;

    /// 跟随摄像机的精灵
    if (camera.sprite != null) {
      if (camera.limit != null) {
        /// 限制边界
        moveX = camera.rect.width / 2 - camera.sprite!.position.x;
        moveY = camera.rect.height / 2 - camera.sprite!.position.y;

        if (camera.sprite!.position.x <= camera.rect.width / 2) {
          moveX = 0;
        }
        if (camera.sprite!.position.y <= camera.rect.height / 2) {
          moveY = 0;
        }
        if (camera.sprite!.position.x >= camera.limit!.dx - camera.rect.width / 2) {
          moveX = camera.rect.width - camera.limit!.dx;
        }
        if (camera.sprite!.position.y >= camera.limit!.dy - camera.rect.height / 2) {
          moveY = camera.rect.height - camera.limit!.dy;
        }
      } else {
        moveX = camera.rect.width / 2 - camera.sprite!.position.x;
        moveY = camera.rect.height / 2 - camera.sprite!.position.y;
      }
      canvas.translate(moveX, moveY);
    }

    children.forEach((sprite) {
      if (sprite.visible) {
        if (!sprite.fixed) {
          sprite.render(canvas);
        }
      }
    });

    /// 固定到屏幕位置的精灵
    if (camera.sprite != null) {
      canvas.translate(-moveX, -moveY);
    }
    children.forEach((sprite) {
      if (sprite.visible) {
        if (sprite.fixed) {
          sprite.render(canvas);
        }
      }
    });

    canvas.restore();
  }

  /// 生命周期发生变化
  void lifecycleStateChange(AppLifecycleState state) {}
}
