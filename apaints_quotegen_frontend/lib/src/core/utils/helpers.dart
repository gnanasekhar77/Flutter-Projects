import 'package:APaints_QGen/src/core/utils/date_utils.dart';
import 'package:APaints_QGen/src/data/datasources/remote/app_config_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/app_settings_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/easy_localization_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'get_it.dart';

double fallbackLat = 18.4962;
double fallbackLong = 73.8007;

String capitalize(String word) {
  word = word.toLowerCase();
  var d = word.split(' ');
  return d.map((e) => '${e[0].toUpperCase()}${e.substring(1)}').join(' ');
}

Size displaySize(BuildContext context) {
  return MediaQuery.of(context).size;
}

double displayHeight(BuildContext context) {
  return displaySize(context).height;
}

double displayWidth(BuildContext context) {
  return displaySize(context).width;
}

bool isDark(BuildContext context) {
  return context.read<AppSettingsProvider>().isDark;
}

void showSnackBar({String? message, bool showHideButton = true}) {
  getSingleton<AppConfigProvider>().globalSnackbar(message, showHideButton);
}

extension TranslationExtensionText on Text {
  Text translate({Map<String, String>? namedArgs}) => Text(
        getSingleton<EasyLocalizationProvider>().translate(data, namedArgs),
        key: key,
        style: style,
        strutStyle: strutStyle,
        textAlign: textAlign,
        textDirection: textDirection,
        locale: locale,
        softWrap: softWrap,
        overflow: overflow,
        textScaleFactor: textScaleFactor,
        maxLines: maxLines,
        semanticsLabel: semanticsLabel,
        textWidthBasis: textWidthBasis,
      );
}

extension StringExtensions on String {
  String translate({Map<String, String>? namedArgs}) {
    String retString = this;
    try {
      retString =
          getSingleton<EasyLocalizationProvider>().translate(this, namedArgs);
      return retString;
    } catch (_) {
      return retString;
    }
  }

  String capitalize() {
    String lowerCase = toLowerCase();
    var d = lowerCase.split(' ');
    return d.map((e) => '${e[0].toUpperCase()}${e.substring(1)}').join(' ');
  }

  String handleOverflow(int length) {
    return this.length > length ? substring(0, length) + '...' : this;
  }
}

bool isNumeric(String s) {
  if (s.isEmpty) {
    return false;
  }
  return double.tryParse(s) != null;
}

// MarkerIdProv getId(double latitude, double longitude) {
//   return MarkerIdProv([longitude, latitude].join("#").toString());
// }

extension ListExtension on List<String> {
  bool containsSubString(String subStr) {
    return any((element) => element.contains(subStr));
  }
}

extension PaddingExtension on Widget {
  Widget pad(EdgeInsetsGeometry padding) {
    return Padding(
      padding: padding,
      child: this,
    );
  }
}

String convertTimeSlot(String? time) {
  return (formatDate(
          parseFromDateStringUsingFormat(time?.split(':')[0] ?? '', 'h'),
          'h a') ??
      '');
}
