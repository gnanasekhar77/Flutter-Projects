import 'package:APaints_QGen/src/core/utils/colors.dart';
import 'package:APaints_QGen/src/core/utils/helpers.dart';
import 'package:flutter/material.dart';

class FRElevatedButton extends StatefulWidget {
  final void Function()? onPressed;
  final Widget label;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool? isEnabled;

  const FRElevatedButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.padding,
    this.margin,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  _FRElevatedButtonState createState() => _FRElevatedButtonState();
}

class _FRElevatedButtonState extends State<FRElevatedButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.isEnabled! ? widget.onPressed : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: AsianPaintColors.buttonColor,
          borderRadius: BorderRadius.circular(10),
        ),
        width: displayWidth(context) * 0.9,
        height: displayHeight(context) * 0.075,
        child: Center(
          child: widget.label,
        ),
      ),
    );
  }
}
