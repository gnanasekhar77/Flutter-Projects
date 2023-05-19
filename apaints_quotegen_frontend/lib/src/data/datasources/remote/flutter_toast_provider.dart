import 'package:APaints_QGen/src/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FlutterToastProvider {
  void show({required String message, String? status}) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: status == null ? Toast.LENGTH_SHORT : Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 2,
        textColor: AsianPaintColors.whiteColor,
        fontSize: 16.0,
        webPosition: "center",
        backgroundColor: Colors.black,
        webBgColor: "black");
  }
}
