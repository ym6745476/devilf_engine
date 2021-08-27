import 'dart:async';
import 'package:devilf_engine/core/df_position.dart';
import 'package:devilf_engine/core/df_rect.dart';
import 'package:devilf_engine/core/df_size.dart';
import 'package:devilf_engine/game/df_camera.dart';
import 'package:devilf_engine/game/df_game_widget.dart';
import 'package:devilf_engine/sprite/df_image_sprite.dart';
import 'package:devilf_engine/sprite/df_text_sprite.dart';
import 'package:example/building/stone_sprite.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../game_manager.dart';

class GameScene extends StatefulWidget {
  final int map;

  GameScene({this.map = 1});

  @override
  _GameSceneState createState() => _GameSceneState();
}

class _GameSceneState extends State<GameScene> with TickerProviderStateMixin {
  /// 主界面
  DFGameWidget? _gameWidget;

  /// 加载状态
  bool _loading = true;

  /// 创建主场景
  _GameSceneState();

  /// 初始化状态
  @override
  void initState() {
    super.initState();

    /// 强制横屏
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

    /// 加载游戏
    _loadGame();
  }

  /// 开始进入游戏
  void _loadGame() async {
    try {
      await Future.delayed(Duration(seconds: 1), () async {
        /// 摄像机
        DFCamera camera = DFCamera(rect: DFRect(0, 0, GameManager.visibleWidth, GameManager.visibleHeight));

        /// 定义主界面
        this._gameWidget =
            DFGameWidget(size: Size(GameManager.visibleWidth, GameManager.visibleHeight), camera: camera);

        /// Logo精灵
        DFImageSprite logoSprite = await DFImageSprite.load("assets/images/sprite.png");
        logoSprite.scale = 0.4;
        logoSprite.size = DFSize(40, 40);
        logoSprite.position =
            DFPosition(MediaQuery.of(context).size.width - 110, MediaQuery.of(context).padding.top + 30);
        logoSprite.fixed = true;

        /// 帧数精灵
        DFTextSprite fpsSprite = DFTextSprite("60 fps");
        fpsSprite.position =
            DFPosition(MediaQuery.of(context).size.width - 70, MediaQuery.of(context).padding.top + 30);
        fpsSprite.fixed = true;
        fpsSprite.setOnUpdate((dt) {
          fpsSprite.text = this._gameWidget!.fps.toStringAsFixed(0) + " fps";
        });

        /// 演示精灵
        StoneSprite stoneSprite = StoneSprite();
        stoneSprite.scale = 4;
        stoneSprite.position =
            DFPosition(MediaQuery.of(context).size.width / 2, MediaQuery.of(context).size.height / 2);

        /// 将Logo精灵添加到主界面
        this._gameWidget!.addChild(logoSprite);

        /// 将帧数精灵添加到主界面
        this._gameWidget!.addChild(fpsSprite);

        /// 将演示精灵精灵添加到主界面
        this._gameWidget!.addChild(stoneSprite);

        /// 设置摄像机跟随
        camera.lookAt(stoneSprite);

        /// 保存到管理器里
        GameManager.gameWidget = this._gameWidget!;

        /// Loading完成
        setState(() {
          _loading = false;
        });

        print("游戏加载完成...");
      });
    } catch (e) {
      print('(GameScene _loadGame) Error: $e');
    }
  }

  /// Loading显示
  Widget _loadingWidget() {
    return Center(
      child:
          Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
        CircularProgressIndicator(),
        Padding(
          padding: EdgeInsets.only(top: 16),
          child: Text(
            "Loading...",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    /// 获取屏幕尺寸
    GameManager.visibleWidth = MediaQuery.of(context).size.width;
    GameManager.visibleHeight = MediaQuery.of(context).size.height;
    print("获取屏幕尺寸:" + GameManager.visibleWidth.toString() + "," + GameManager.visibleHeight.toString());

    return Container(
      color: Colors.black87,
      child: _loading
          ? _loadingWidget()
          : Stack(fit: StackFit.expand, children: <Widget>[
              /// 游戏控件
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: Colors.black87,
                  child: _gameWidget,
                ),
              ),

              /// Logo
              Positioned(
                left: 20,
                top: MediaQuery.of(context).padding.top + 20,
                child: Text(
                  "DevilF",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ]),
    );
  }
}
