// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';

var locator = GetIt.instance;

T getSingleton<T extends Object>() {
  return locator.get<T>();
}

T getProvider<T extends Object>(BuildContext context, {bool listen = true}) {
  return Provider.of<T>(context, listen: listen);
}
