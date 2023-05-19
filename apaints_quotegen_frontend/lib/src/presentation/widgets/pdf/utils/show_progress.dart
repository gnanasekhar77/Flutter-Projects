import 'dart:io';

import 'package:APaints_QGen/src/core/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef LoadingWidget = Widget Function();

class ShowProgress extends StatelessWidget {
  /// progress optional only worked with android
  const ShowProgress({Key? key, this.progress}) : super(key: key);
  final double? progress;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Platform.isIOS
          ? CupertinoActivityIndicator(
              color: AsianPaintColors.textFieldLabelColor,
            )
          : CircularProgressIndicator(
              color: AsianPaintColors.textFieldLabelColor,
              value: progress,
            ),
    );
  }
}

Widget loadingWidgetHolder() => const ShowProgress();
