import 'dart:core';

import 'package:devilf_engine/core/df_position.dart';

/// A*算法类
class DFAStar {
  static const int BAR = 1; // 障碍
  static const int PATH = 2; // 路径
  static const int DIRECT_VALUE = 10; // 横竖移动代价
  static const int OBLIQUE_VALUE = 14; // 斜移动代价

  List<DFMapNode> _openList = [];
  List<DFMapNode> _closeList = [];
  List<DFMapPosition> _pathList = [];

  /// 开始算法
  Future<List<DFMapPosition>> start(List<List<int>> blockMap, DFMapNode startNode, DFMapNode endNode) async {
    /// Map数据
    DFMap map = DFMap(blockMap, blockMap[0].length, blockMap.length, startNode, endNode);

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
  void moveNodes(DFMap map) {
    while (_openList.length > 0) {
      /// 第一个元素
      DFMapNode current = _openList.removeAt(0);
      _closeList.add(current);
      addNeighborNodeInOpen(map, current);
      if (isPositionInClose(map.end.position)) {
        drawPath(map.maps, map.end);
        break;
      }
    }
  }

  /// 在二维数组中绘制路径
  void drawPath(List<List<int>>? maps, DFMapNode? end) {
    if (end == null || maps == null) return;
    print("总代价：" + end.G.toString());
    while (end != null) {
      DFMapPosition c = end.position!;
      maps[c.y][c.x] = PATH;
      end = end.parent;
      _pathList.add(DFMapPosition(c.x, c.y));
    }
  }

  /// 添加所有邻结点到open表
  void addNeighborNodeInOpen(DFMap mapInfo, DFMapNode current) {
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
  void addNeighborNodeInOpenXy(DFMap mapInfo, DFMapNode current, int x, int y, int value) {
    if (canAddNodeToOpen(mapInfo, x, y)) {
      DFMapNode end = mapInfo.end;
      DFMapPosition position = DFMapPosition(x, y);
      int G = current.G + value; // 计算邻结点的G值
      DFMapNode? child = findNodeInOpen(position);
      if (child == null) {
        int H = calcH(end.position!, position); // 计算H值
        if (isEndNode(end.position!, position)) {
          child = end;
          child.parent = current;
          child.G = G;
          child.H = H;
        } else {
          child = DFMapNode.newNode(position, current, G, H);
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
  DFMapNode? findNodeInOpen(DFMapPosition? position) {
    if (position == null || _openList.length == 0) return null;
    for (DFMapNode node in _openList) {
      if (node.position! == position) {
        return node;
      }
    }
    return null;
  }

  /// 计算H的估值：“曼哈顿”法，坐标分别取差值相加
  int calcH(DFMapPosition end, DFMapPosition coord) {
    return ((end.x - coord.x).abs() + (end.y - coord.y).abs()) * DIRECT_VALUE;
  }

  /// 判断结点是否是最终结点
  bool isEndNode(DFMapPosition end, DFMapPosition? position) {
    return position != null && end == position;
  }

  /// 判断结点能否放入Open列表
  bool canAddNodeToOpen(DFMap mapInfo, int x, int y) {
    /// 是否在地图中
    if (x < 0 || x >= mapInfo.width || y < 0 || y >= mapInfo.height) return false;

    /// 判断是否是不可通过的结点
    if (mapInfo.maps![y][x] == BAR) return false;

    /// 判断结点是否存在close表
    if (isCoordInCloseXy(x, y)) return false;

    return true;
  }

  /// 判断坐标是否在close表中
  bool isPositionInClose(DFMapPosition? position) {
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
    for (DFMapNode node in _closeList) {
      if (node.position!.x == x && node.position!.y == y) {
        return true;
      }
    }
    return false;
  }
}

/// 包含地图所需的所有输入数据
class DFMap {
  /// 二维数组的地图
  List<List<int>>? maps;

  /// 地图的宽
  int width;

  /// 地图的高
  int height;

  /// 起始结点
  DFMapNode start;

  /// 最终结点
  DFMapNode end;

  DFMap(this.maps, this.width, this.height, this.start, this.end);
}

/// 路径节点
class DFMapNode {
  DFMapPosition? position; // 坐标
  DFMapNode? parent; // 父结点
  int G = 0; // G：是个准确的值，是起点到当前结点的代价
  int H = 0; // H：是个估值，当前结点到目的结点的估计代价

  DFMapNode(int x, int y) {
    this.position = new DFMapPosition(x, y);
  }

  DFMapNode.newNode(DFMapPosition position, DFMapNode parent, int g, int h) {
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
  int compareTo(DFMapNode other) {
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

/// 坐标
class DFMapPosition {
  int x;
  int y;

  DFMapPosition(this.x, this.y);

  @override
  bool operator ==(Object other) {
    if (other is DFMapPosition) {
      return x == other.x && y == other.y;
    }
    return false;
  }

  @override
  String toString() {
    return "x:" + x.toString() + ",y:" + y.toString();
  }
}
