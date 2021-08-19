import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// 选择按钮
class DFCheckButton extends StatefulWidget {
  final int value;
  final String? text;
  final double fontSize;
  final Color textColor;
  final FontWeight fontWeight;
  final Size size;
  final String image;
  final String checkedImage;
  final Function(DFCheckButton button,bool checked, int value) onChanged;

  Function setChecked = (bool checked) {
    print("DFCheckButton setChecked:" + checked.toString());
  };

  DFCheckButton({
    required this.value,
    required this.onChanged,
    required this.image,
    required this.checkedImage,
    this.text,
    this.fontSize = 14,
    this.textColor = const Color(0xFFFFFFFF),
    this.fontWeight = FontWeight.normal,
    this.size = const Size(80, 80),
  });

  @override
  _DFCheckButtonState createState() => _DFCheckButtonState();
}

class _DFCheckButtonState extends State<DFCheckButton> {
  Color? _color;
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    widget.setChecked = this.setChecked;
  }

  void setChecked(bool checked) {
    print("setChecked:" + checked.toString());
    setState(() {
      _checked = checked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: widget.size.width,
        height: widget.size.height,
        child: GestureDetector(
          onTap: () {
            setState(() {
              this._checked = !this._checked;
            });
            widget.onChanged(widget,this._checked, widget.value);
          },
          onTapDown: (detail) {
            setState(() {
              this._color = Colors.black54;
            });
          },
          onTapCancel: () {
            setState(() {
              this._color = null;
            });
          },
          onTapUp: (detail) {
            setState(() {
              this._color = null;
            });
          },
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  child: Image.asset(
                    _checked ? widget.checkedImage : widget.image,
                    fit: BoxFit.fill,
                    width: widget.size.width,
                    height: widget.size.height,
                    color: this._color,
                    colorBlendMode: BlendMode.dstIn,
                  ),
                ),
                widget.text != null?
                Container(
                  padding: EdgeInsets.only(left: 5),
                  child: Text(
                    widget.text!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: widget.textColor,
                      fontSize: widget.fontSize,
                      fontWeight: widget.fontWeight,
                    ),
                  ),
                ):Container(),
              ]),
        ));
  }
}
