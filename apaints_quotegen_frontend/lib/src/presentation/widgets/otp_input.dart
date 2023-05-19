// Create an input widget that takes only one digit
import 'package:APaints_QGen/responsive.dart';
import 'package:APaints_QGen/src/core/utils/colors.dart';
import 'package:flutter/material.dart';

class OtpInput extends StatelessWidget {
  final TextEditingController controller;
  final bool autoFocus;
  const OtpInput(this.controller, this.autoFocus, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Responsive(
      mobile: Theme(
        data: ThemeData(),
        child: SizedBox(
          height: 50,
          width: 50,
          child: TextField(
            enableInteractiveSelection: false,
            autofocus: autoFocus,
            textAlign: TextAlign.center,
            keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
            controller: controller,
            maxLength: 1,
            cursorColor: AsianPaintColors.chooseYourAccountColor,
            decoration: InputDecoration(
              filled: true,
              fillColor: AsianPaintColors.bottomTextUnSelectedColor,
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                color: AsianPaintColors.bottomTextUnSelectedColor,
                width: 3,
              )),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                color: AsianPaintColors.bottomTextUnSelectedColor,
                width: 3,
              )),
              border: OutlineInputBorder(
                  borderSide: BorderSide(
                color: AsianPaintColors.bottomTextUnSelectedColor,
                width: 3,
              )),
              focusColor: AsianPaintColors.bottomTextUnSelectedColor,
              hoverColor: AsianPaintColors.bottomTextUnSelectedColor,
              counterText: '',
              hintStyle: TextStyle(
                  color: AsianPaintColors.bottomTextColor, fontSize: 15.0),
            ),
            onChanged: (value) {
              if (value.length == 1) {
                FocusScope.of(context).nextFocus();
              }
            },
          ),
        ),
      ),
      tablet: const Scaffold(),
      desktop: Theme(
        data: ThemeData(),
        child: SizedBox(
          height: 40,
          width: 40,
          child: TextField(
            enableInteractiveSelection: false,
            autofocus: autoFocus,
            textAlign: TextAlign.center,
            keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
            controller: controller,
            maxLength: 1,
            cursorColor: AsianPaintColors.chooseYourAccountColor,
            decoration: InputDecoration(
              filled: true,
              fillColor: AsianPaintColors.whiteColor,
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                color: AsianPaintColors.whiteColor,
                width: 2,
              )),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                color: AsianPaintColors.whiteColor,
                width: 2,
              )),
              border: OutlineInputBorder(
                  borderSide: BorderSide(
                color: AsianPaintColors.bottomTextUnSelectedColor,
                width: 2,
              )),
              focusColor: AsianPaintColors.bottomTextUnSelectedColor,
              hoverColor: AsianPaintColors.bottomTextUnSelectedColor,
              counterText: '',
              hintStyle: TextStyle(
                  color: AsianPaintColors.bottomTextColor, fontSize: 15.0),
            ),
            onChanged: (value) {
              if (value.length == 1) {
                FocusScope.of(context).nextFocus();
              }
            },
          ),
        ),
      ),
    );
  }
}
