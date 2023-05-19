abstract class CopyQuoteState {}

class CopyQuoteInitial extends CopyQuoteState {}

class CopyQuoteLoading extends CopyQuoteState {}

class CopyQuoteFailure extends CopyQuoteState {
  final String message;

  CopyQuoteFailure({required this.message});
}

class CopyQuoteLoaded extends CopyQuoteState {}

class CopyQuoteReLoaded extends CopyQuoteState {}
