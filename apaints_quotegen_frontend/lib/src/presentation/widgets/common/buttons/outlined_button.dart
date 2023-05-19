import 'package:APaints_QGen/src/core/utils/edge_insets.dart';
import 'package:flutter/material.dart';

class APOutlinedButton extends StatefulWidget {
  final void Function()? onPressed;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Widget label;
  const APOutlinedButton({
    Key? key,
    this.onPressed,
    this.margin,
    this.padding,
    required this.label,
  }) : super(key: key);

  @override
  _APOutlinedButtonState createState() => _APOutlinedButtonState();
}

class _APOutlinedButtonState extends State<APOutlinedButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.margin ?? AsianPaintEdgeInsets.horizontal_20,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: widget.padding,
        ),
        onPressed: widget.onPressed,
        child: widget.label,
      ),
    );
  }
}
