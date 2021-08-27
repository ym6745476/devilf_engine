import 'dart:core';

import 'package:devilf_engine/core/df_position.dart';

/// A*算法类
class DFAStar {
  static const int BAR = 1; // 障碍
  static const int PATH = 2; // 路径
  static const int DIRECT_VALUE = 10; // 横竖移动代价
  static const int OBLIQUE_VALUE = 14; // 斜移动代价

  List<DFAStarNode> _openList = [];
  List<DFAStarNode> _closeList = [];
  List<DFTilePosition> _pathList = [];

  /// 开始算法
  Future<List<DFTilePosition>> start(List<List<int>> blockMap, DFAStarNode startNode, DFAStarNode endNode) async {
    /// Map数据
    DFAStarMap map = DFAStarMap(blockMap, blockMap[0].length, blockMap.length, startNode, endNode);

    /// clean
    _openList.clear();
    _closeList.clear();
    _pathList.clear();

    /// 开始搜索
    _openList.add(map.start);

    /// 优先队列(升序)
    _openList.sort((a, b) => a.compareTo(b));
    moveNodes(map);

    /// 删掉起点
    if (this._pathList.length > 0) {
      this._pathList.removeLast();
    }

    /// 返回路径
    return this._pathList;
  }

  /// 移动当前结点
  void moveNodes(DFAStarMap map) {
    while (_openList.length > 0) {
      /// 第一个元素
      DFAStarNode current = _openList.removeAt(0);
      _closeList.add(current);
      addNeighborNodeInOpen(map, current);
      if (isPositionInClose(map.end.position)) {
        drawPath(map.maps, map.end);
        break;
      }
    }
  }

  /// 在二维数组中绘制路径
  void drawPath(List<List<int>>? maps, DFAStarNode? end) {
    if (end == null || maps == null) return;
    print("总代价：" + end.G.toString());
    while (end != null) {
      DFTilePosition c = end.position!;
      maps[c.y][c.x] = PATH;
      end = end.parent;
      _pathList.add(DFTilePosition(c.x, c.y));
    }
  }

  /// 添加所有邻结点到open表
  void addNeighborNodeInOpen(DFAStarMap mapInfo, DFAStarNode current) {
    int x = current.position!.x;
    int y = current.position!.y;
    // 左
    addNeighborNodeInOpenXy(mapInfo, current, x - 1, y, DIRECT_VALUE);
    // 上
    addNeighborNodeInOpenXy(mapInfo, current, x, y - 1, DIRECT_VALUE);
    // 右
    addNeighborNodeInOpenXy(mapInfo, current, x + 1, y, DIRECT_VALUE);
    // 下
    addNeighborNodeInOpenXy(mapInfo, current, x, y + 1, DIRECT_VALUE);
    // 左上
    addNeighborNodeInOpenXy(mapInfo, current, x - 1, y - 1, OBLIQUE_VALUE);
    // 右上
    addNeighborNodeInOpenXy(mapInfo, current, x + 1, y - 1, OBLIQUE_VALUE);
    // 右下
    addNeighborNodeInOpenXy(mapInfo, current, x + 1, y + 1, OBLIQUE_VALUE);
    // 左下
    addNeighborNodeInOpenXy(mapInfo, current, x - 1, y + 1, OBLIQUE_VALUE);
  }

  /// 添加一个邻结点到open表
  void addNeighborNodeInOpenXy(DFAStarMap mapInfo, DFAStarNode current, int x, int y, int value) {
    if (canAddNodeToOpen(mapInfo, x, y)) {
      DFAStarNode end = mapInfo.end;
      DFTilePosition position = DFTilePosition(x, y);
      int G = current.G + value; // 计算邻结点的G值
      DFAStarNode? child = findNodeInOpen(position);
      if (child == null) {
        int H = calcH(end.position!, position); // 计算H值
        if (isEndNode(end.position!, position)) {
          child = end;
          child.parent = current;
          child.G = G;
          child.H = H;
        } else {
          child = DFAStarNode.newNode(position, current, G, H);
        }
        _openList.add(child);
        _openList.sort((a, b) => a.compareTo(b));
      } else if (child.G > G) {
        child.G = G;
        child.parent = current;
        _openList.add(child);
        _openList.sort((a, b) => a.compareTo(b));
      }
    }
  }

  /// 从Open列表中查找结点
  DFAStarNode? findNodeInOpen(DFTilePosition? position) {
    if (position == null || _openList.length == 0) return null;
    for (DFAStarNode node in _openList) {
      if (node.position! == position) {
        return node;
      }
    }
    return null;
  }

  /// 计算H的估值：“曼哈顿”法，坐标分别取差值相加
  int calcH(DFTilePosition end, DFTilePosition coord) {
    return ((end.x - coord.x).abs() + (end.y - coord.y).abs()) * DIRECT_VALUE;
  }

  /// 判断结点是否是最终结点
  bool isEndNode(DFTilePosition end, DFTilePosition? position) {
    return position != null && end == position;
  }

  /// 判断结点能否放入Open列表
  bool canAddNodeToOpen(DFAStarMap mapInfo, int x, int y) {
    /// 是否在地图中
    if (x < 0 || x >= mapInfo.width || y < 0 || y >= mapInfo.height) return false;

    /// 判断是否是不可通过的结点
    if (mapInfo.maps![y][x] == BAR) return false;

    /// 判断结点是否存在close表
    if (isCoordInCloseXy(x, y)) return false;

    return true;
  }

  /// 判断坐标是否在close表中
  bool isPositionInClose(DFTilePosition? position) {
    if (position == null) {
      return false;
    }
    return isCoordInCloseXy(position.x, position.y);
  }

  /// 判断坐标是否在close表中
  bool isCoordInCloseXy(int x, int y) {
    if (_closeList.length == 0) {
      return false;
    }
    for (DFAStarNode node in _closeList) {
      if (node.position!.x == x && node.position!.y == y) {
        return true;
      }
    }
    return false;
  }
}

/// 包含地图所需的所有输入数据
class DFAStarMap {
  /// 二维数组的地图
  List<List<int>>? maps;

  /// 地图的宽
  int width;

  /// 地图的高
  int height;

  /// 起始结点
  DFAStarNode start;

  /// 最终结点
  DFAStarNode end;

  DFAStarMap(this.maps, this.width, this.height, this.start, this.end);
}

/// 路径节点
class DFAStarNode {
  DFTilePosition? position; // 坐标
  DFAStarNode? parent; // 父结点
  int G = 0; // G：是个准确的值，是起点到当前结点的代价
  int H = 0; // H：是个估值，当前结点到目的结点的估计代价

  DFAStarNode(int x, int y) {
    this.position = new DFTilePosition(x, y);
  }

  DFAStarNode.newNode(DFTilePosition position, DFAStarNode parent, int g, int h) {
    this.position = position;
    this.parent = parent;
    this.G = g;
    this.H = h;
  }

  @override
  String toString() {
    return position.toString();
  }

  /// 排序比较
  int compareTo(DFAStarNode other) {
    /// 大于
    if (G + H > other.G + other.H) {
      return 1;
    }

    /// 小于
    else if (G + H < other.G + other.H) {
      return -1;
    }

    /// 等于
    return 0;
  }
}

