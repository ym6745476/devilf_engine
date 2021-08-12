import 'dart:ui';
import 'package:devilf_engine/core/df_circle.dart';
import 'package:devilf_engine/core/df_position.dart';
import 'package:devilf_engine/core/df_shape.dart';
import 'package:devilf_engine/core/df_size.dart';
import 'package:devilf_engine/game/df_assets_loader.dart';
import 'package:devilf_engine/game/df_camera.dart';
import 'package:devilf_engine/core/df_rect.dart';
import 'package:devilf_engine/sprite/df_sprite.dart';
import 'package:devilf_engine/tiled/df_tile.dart';
import 'package:devilf_engine/tiled/df_tile_layer.dart';
import 'package:devilf_engine/tiled/df_tile_set.dart';
import 'package:devilf_engine/tiled/df_tile_map.dart';
import 'dart:ui' as ui;
import '../devilf_engine.dart';
import 'df_image_sprite.dart';

/// 瓦片地图精灵
class DFTileMapSprite extends DFSprite {

  /// 瓦片地图
  DFTileMap? tileMap;

  /// 需要绘制的瓦片
  List<DFImageSprite> sprites = [];

  /// 图片资源路径
  String imagePath = "";

  /// 摄像机位置
  DFPosition? cameraPosition;

  /// 地图层
  DFTileLayer? mapLayer;

  /// 遮挡层
  DFTileLayer? alphaLayer;

  /// 碰撞层
  DFTileLayer? blockLayer;

  /// 创建地图精灵
  DFTileMapSprite({
    DFSize size = const DFSize(100, 100),
  }) : super(position: DFPosition(0, 0), size: size);

  /// 读取tiled导出的json文件
  static Future<DFTileMapSprite> load(String json, double scale) async {
    DFTileMapSprite tileMapSprite = DFTileMapSprite();
    Map<String, dynamic> jsonMap = await DFAssetsLoader.loadJson(json);
    tileMapSprite.tileMap = DFTileMap.fromJson(jsonMap);
    tileMapSprite.imagePath = json.substring(0, json.lastIndexOf("/"));
    tileMapSprite.scale = scale;
    tileMapSprite.tileMap!.layers!.forEach((layer) {
      if (layer is DFTileLayer && layer.name == "map" && layer.visible == true) {
        tileMapSprite.mapLayer = layer;
      } else if (layer is DFTileLayer && layer.name == "block") {
        tileMapSprite.blockLayer = layer;
      } else if (layer is DFTileLayer && layer.name == "alpha") {
        tileMapSprite.alphaLayer = layer;
      }
    });
    return tileMapSprite;
  }

  /// 更细地图瓦片
  Future<void> updateLayer(DFCamera camera) async {
    if (this.tileMap == null) return;

    /// 上一下刷新时摄像机的位置
    if (this.cameraPosition != null) {
      if ((this.cameraPosition!.x - camera.sprite!.position.x).abs() < this.tileMap!.tileWidth! * 5 * scale &&
          (this.cameraPosition!.y - camera.sprite!.position.y).abs() < this.tileMap!.tileHeight! * 5 * scale) {
        return;
      }
    }

    /// 保存上一下刷新时摄像机的位置
    this.cameraPosition = DFPosition(camera.sprite!.position.x, camera.sprite!.position.y);
    double drawX = camera.sprite!.position.x - camera.rect.width / 2;
    double drawY = camera.sprite!.position.y - camera.rect.height / 2;

    /// 可视区域
    DFRect visibleRect = DFRect(drawX, drawY, camera.rect.width + this.tileMap!.tileWidth! * 10 * scale,
        camera.rect.height + this.tileMap!.tileHeight! * 10 * scale);

    /// print("visibleRect:" + visibleRect.toString());

    /// 将全部的瓦片设置为不可见
    sprites.forEach((element) {
      element.visible = false;
    });

    /// 遍历图层瓦片
    if (mapLayer != null) {
      DFTileSet? tileSet;
      double tileWidth = 0;
      double tileHeight = 0;
      int columnCount = 0;
      await Future.forEach<int>(mapLayer!.data ?? [], (tile) async {
        if (tile != 0) {
          if (tileSet == null) {
            tileSet = tileMap!.tileSets!.lastWhere((element) {
              return element.firsTgId != null && tile >= element.firsTgId!;
            });
            columnCount = (tileMap!.width! * tileMap!.tileWidth!) ~/ tileSet!.tileWidth!.toDouble();
            tileWidth = tileSet!.tileWidth!.toDouble() * this.scale;
            tileHeight = tileSet!.tileHeight!.toDouble() * this.scale;
          }
          if (tileSet != null) {
            int tileIndex = tile - tileSet!.firsTgId!;
            int row = _getY(tileIndex, columnCount).toInt();
            int column = _getX(tileIndex, columnCount).toInt();

            /// print("row:" + row.toString() + ",column:" + column.toString() + ",scale:" + this.scale.toString());
            Rect tileRect = Rect.fromLTWH(column * tileWidth, row * tileHeight, tileWidth, tileHeight);

            /// print("tileRect:" + tileRect.toString());
            /// 在可视区域的瓦片设置为显示
            if (visibleRect.toRect().overlaps(tileRect)) {
              DFImageSprite? imageSprite = existImageSprite(row, column);
              if (imageSprite == null) {
                imageSprite = await getTileImageSprite(tileSet!, tileIndex, row, column, this.scale);
                sprites.add(imageSprite);
              } else {
                imageSprite.visible = true;
              }
            }
          }
        }
      });
    }

    /// 删除不可见的精灵
    sprites.removeWhere((element) => !element.visible);
  }

  /// 获取存在的精灵
  DFImageSprite? existImageSprite(int row, int column) {
    for (DFImageSprite sprite in sprites) {
      if (row.toString() + "," + column.toString() == sprite.key) {
        return sprite;
      }
    }
    return null;
  }

  /// 获取瓦片精灵的某个瓦片
  Future<DFImageSprite> getTileImageSprite(DFTileSet tileSet, int tileIndex, int row, int column, double scale) async {
    ///print("index:" + index.toString());

    List<DFTile>? tiles = tileSet.tiles;
    String imagePath = this.imagePath + "/";
    double tileWidth = tileSet.tileWidth!.toDouble();
    double tileHeight = tileSet.tileHeight!.toDouble();
    double imageWidth = 0;
    double imageHeight = 0;

    if (tiles != null) {
      DFTile tile = tiles[tileIndex];
      imageWidth = tile.imageWidth!.toDouble();
      imageHeight = tile.imageHeight!.toDouble();
      imagePath = this.imagePath + "/" + tile.image!;

      /// print(imagePath);
    } else {
      imageWidth = tileSet.imageWidth!.toDouble();
      imageHeight = tileSet.imageHeight!.toDouble();
      imagePath = this.imagePath + "/" + tileSet.image!;
    }

    /// Image创建
    ui.Image image = await DFAssetsLoader.loadImage(imagePath);
    DFImageSprite sprite = DFImageSprite(
      image,
      rect: DFRect(0, 0, imageWidth, imageHeight),
      rotated: false,
    );
    sprite.scale = scale;
    sprite.position = DFPosition(
        column * tileWidth * scale + tileWidth / 2 * scale, row * tileHeight * scale + tileHeight / 2 * scale);
    sprite.key = row.toString() + "," + column.toString();
    return sprite;
  }

  /// 获取列
  double _getX(int index, int width) {
    return (index % width).toDouble();
  }

  /// 获取行
  double _getY(int index, int width) {
    return (index / width).floor().toDouble();
  }

  /// 检查碰撞和遮挡
  /// 遮挡1
  /// 碰撞2
  /// 没有0
  int isCollided(DFShape shape) {
    bool isBlock = false;
    bool isAlpha = false;

    if (blockLayer != null && alphaLayer != null) {
      List<DFPosition> points = [];
      if (shape is DFRect) {
        points.add(DFPosition(shape.left, shape.top));
        points.add(DFPosition(shape.right, shape.top));
        points.add(DFPosition(shape.right, shape.bottom));
        points.add(DFPosition(shape.left, shape.bottom));
      } else if (shape is DFCircle) {
        points.add(DFPosition(shape.center.x - shape.radius, shape.center.y - shape.radius));
        points.add(DFPosition(shape.center.x + shape.radius, shape.center.y - shape.radius));
        points.add(DFPosition(shape.center.x - shape.radius, shape.center.y + shape.radius));
        points.add(DFPosition(shape.center.x + shape.radius, shape.center.y + shape.radius));
      }

      int columnCount = tileMap!.width!;
      double scaledTiledWidth = this.tileMap!.tileWidth! * this.scale;
      double scaledTiledHeight = this.tileMap!.tileHeight! * this.scale;

      /// 获取形状的4个点进行判断碰撞，比遍历性能会高很多
      for (int i = 0; i < points.length; i++) {
        int row = (points[i].y / scaledTiledHeight).ceil() - 1;
        int column = (points[i].x / scaledTiledWidth).ceil() - 1;

        /// print("row:" + row.toString() + ",column:" + column.toString());
        int index = row * columnCount + column;

        /// print("index:" + index.toString());
        if (blockLayer!.data![index] != 0) {
          isBlock = true;
          break;
        } else if (alphaLayer!.data![index] != 0) {
          isAlpha = true;
        }
      }
    }
    if (isBlock) {
      return 2;
    } else if (isAlpha) {
      return 1;
    }
    return 0;
  }

  /// 绘制碰撞层和遮挡层
  void drawBlockAndAlphaLayer(Canvas canvas) {
    if (blockLayer != null && this.cameraPosition != null) {
      /// 可视区域
      DFCircle visibleShape = DFCircle(this.cameraPosition!, 300);

      /// print("visibleRect:" + visibleRect.toString());
      int columnCount = tileMap!.width!;
      double tileWidth = tileMap!.tileWidth!.toDouble() * this.scale;
      double tileHeight = tileMap!.tileHeight!.toDouble() * this.scale;

      for (int i = 0; i < blockLayer!.data!.length; i++) {
        if (blockLayer!.data![i] != 0) {
          var paint = new Paint()..color = Color(0x60f05b72);
          int row = _getY(i, columnCount).toInt();
          int column = _getX(i, columnCount).toInt();
          DFRect tileRect = DFRect(column * tileWidth, row * tileHeight, tileWidth, tileHeight);
          if (visibleShape.overlaps(tileRect)) {
            /// 在可视区域的瓦片设置为显示
            canvas.drawRect(tileRect.toRect(), paint);
          }
        } else if (alphaLayer!.data![i] != 0) {
          var paint = new Paint()..color = Color(0x60426ab3);
          int row = _getY(i, columnCount).toInt();
          int column = _getX(i, columnCount).toInt();
          DFRect tileRect = DFRect(column * tileWidth, row * tileHeight, tileWidth, tileHeight);
          if (visibleShape.overlaps(tileRect)) {
            /// 在可视区域的瓦片设置为显示
            canvas.drawRect(tileRect.toRect(), paint);
          }
        }
      }
    }
  }

  /// 精灵更新
  @override
  void update(double dt) {}

  /// 精灵渲染
  @override
  void render(Canvas canvas) {
    /// 画布暂存
    canvas.save();

    /// 将子精灵转换为相对坐标
    canvas.translate(position.x, position.y);

    if (this.sprites.length > 0) {
      this.sprites.forEach((sprite) {
        sprite.render(canvas);
      });
    }

    /// 精灵矩形边界
    /*if(this.cameraPosition!=null){
      var paint = new Paint()..color = Color(0x6000FF00);
      DFRect visibleRect = DFRect(this.cameraPosition!.x - 50,this.cameraPosition!.y -50, 100, 100);
      canvas.drawRect(visibleRect.toRect(), paint);
    }*/

    /// 绘制碰撞层和遮挡层
    if (DFConfig.debug) {
      drawBlockAndAlphaLayer(canvas);
    }

    /// 画布恢复
    canvas.restore();
  }
}
