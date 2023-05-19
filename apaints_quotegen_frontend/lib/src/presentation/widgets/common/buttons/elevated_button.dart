import 'package:APaints_QGen/src/core/utils/colors.dart';
import 'package:APaints_QGen/src/core/utils/constants.dart';
import 'package:APaints_QGen/src/core/utils/edge_insets.dart';
import 'package:APaints_QGen/src/core/utils/fonts.dart';
import 'package:flutter/material.dart';

class APElevatedButton extends StatefulWidget {
  final void Function()? onPressed;
  final Widget label;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool? isEnabled;

  const APElevatedButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.padding,
    this.margin,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  _APElevatedButtonState createState() => _APElevatedButtonState();
}

class _APElevatedButtonState extends State<APElevatedButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.margin ?? AsianPaintEdgeInsets.horizontal_20,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(35.0)),
          backgroundColor: AsianPaintColors.buttonColor,
          shadowColor: AsianPaintColors.buttonBorderColor,
          textStyle: TextStyle(
            color: AsianPaintColors.buttonTextColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            fontFamily: AsianPaintsFonts.mulishMedium,
          ),
        ),
        onPressed: widget.isEnabled! ? widget.onPressed : null,
        child: widget.label,
      ),
    );
  }
}
