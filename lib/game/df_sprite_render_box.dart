import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart' hide WidgetBuilder;
import 'df_game_loop.dart';
import 'df_sprite_widget.dart';

/// 精灵渲染盒
class DFSpriteRenderBox extends RenderBox with WidgetsBindingObserver {
  /// 上下文
  BuildContext context;

  /// 精灵控件
  DFSpriteWidget spriteWidget;

  /// 游戏循环
  DFGameLoop? gameLoop;

  /// 创建渲染盒
  DFSpriteRenderBox(this.context, this.spriteWidget) {
    WidgetsBinding.instance!.addTimingsCallback(spriteWidget.onTimingsCallback);
  }

  /// 附加
  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);

    ///启动游戏循环
    this.gameLoop = DFGameLoop(gameUpdate);
    this.gameLoop?.start();

    ///绑定生命周期监听
    bindLifecycleListener();
  }

  /// 取消附加
  @override
  void detach() {
    super.detach();
    gameLoop?.dispose();
    gameLoop = null;
    unbindLifecycleListener();
  }

  /// 游戏循环更新
  void gameUpdate(double dt) {
    if (!attached) {
      return;
    }
    spriteWidget.update(dt);
    markNeedsPaint();
  }

  /// 绘制界面
  @override
  void paint(PaintingContext context, Offset offset) {
    context.canvas.save();
    context.canvas.translate(offset.dx, offset.dy);
    spriteWidget.render(context.canvas);
    context.canvas.restore();
  }

  /// 事件分发
  @override
  bool hitTest(HitTestResult result, {required Offset position}) {
    if (size.contains(position)) {
      result.add(BoxHitTestEntry(this, position));
      return true;
    }
    return false;
  }

  /// 事件分发
  @override
  bool hitTestSelf(Offset position) => true;

  /// 重绘
  @override
  bool get isRepaintBoundary => true;

  /// 计算尺寸
  @override
  void performLayout() {
    size = constraints.biggest;
  }

  /// 计算布局
  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;

  /// 状态改变
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    spriteWidget.lifecycleStateChange(state);
  }

  /// 监听Widget状态
  void bindLifecycleListener() {
    WidgetsBinding.instance!.addObserver(this);
  }

  /// 不监听Widget状态
  void unbindLifecycleListener() {
    WidgetsBinding.instance!.removeObserver(this);
  }
}
