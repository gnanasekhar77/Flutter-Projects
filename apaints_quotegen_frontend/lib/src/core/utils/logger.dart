import 'dart:developer';

void logger(Object message) {
  log(message.toString());
}

void logES(Object error, StackTrace stackTrace) {
  log('ERROR', error: error);
  log('STACKTRACE', stackTrace: stackTrace);
}
