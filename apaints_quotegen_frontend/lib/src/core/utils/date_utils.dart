import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const String YYYY_MM_DD = 'yyyy-MM-dd';
const String DD_MM_YYYY = 'dd MM yyyy';
const String DDSMMSYYYY = 'dd/MM/yyyy';
const String DD_MMM_YYYY = 'dd MMM, yyyy';
const String DD_MMM = 'dd MMM';
const String MMM_DD = 'MMM dd';
const String DD_MMM_NC_YYYY = 'dd MMM yyyy';
const String HH_MM_A = 'hh:mm a';
const String DD_MMM_YYYY_HH_MM_AP = 'dd MMM, yyyy | hh:mm a';
const String WEEKDAY = 'EE';

DateTime parseFromMilliSeconds(int milliSeconds) =>
    DateTime.fromMillisecondsSinceEpoch(milliSeconds);

DateTime? parseFromDateString(String? date) =>
    date != null && date != '' ? DateTime.parse(date) : null;

DateTime? parseToDateTime(dynamic date) {
  if (date == null) return null;
  if (date.runtimeType == String) {
    return DateTime.parse(date);
  } else if (date.runtimeType == int) {
    return DateTime.fromMillisecondsSinceEpoch(date);
  }
  return null;
}

DateTime parseFromDateStringUsingFormat(String date, String format) {
  return DateFormat(format).parse(date);
}

Map<String, String> charDayToDay = {
  "m": "Monday",
  "t": "Tuesday",
  "w": "Wednesday",
  "th": "Thursday",
  "f": "Friday",
  "s": "Sunday",
  "sa": "Saturday",
};

String? formatDate(DateTime? datetime, String? format,
        [String? fallbackText]) =>
    datetime != null ? DateFormat(format).format(datetime) : fallbackText;

String? formatTimeFromDateTime(DateTime? datetime,
        [bool is24Hours = true, String? fallbackText]) =>
    datetime != null
        ? DateFormat(is24Hours ? 'HH:mm' : 'hh:mm a').format(datetime)
        : fallbackText;

String? formatTimeFromTimeOfDay(TimeOfDay? time,
        [bool is24Hours = true, String? fallbackText]) =>
    time != null
        ? is24Hours
            ? '${time.hour}:${time.minute}'
            : '${time.hourOfPeriod}:${time.minute} ${time.period == DayPeriod.am ? 'AM' : 'PM'}'
        : fallbackText;

// returns true if dates are equal (or if both are null)
bool compareDates(DateTime t1, DateTime t2) {
  bool result = true;
  if (t1 != null && t2 != null) {
    result = t1.day == t2.day && t1.month == t2.month && t1.year == t2.year;
  } else if (t1 != null || t2 != null) {
    result = false;
  }
  return result;
}
