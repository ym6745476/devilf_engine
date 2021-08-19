import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// UI工具类
class DFUiUtil {
  ///显示弹出框
  static showLayer(BuildContext context, Widget child){
    showDialog<Null>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return child;
      },
    ).then((val) {
      print("关闭窗口：" + val.toString());
    });
  }
}
