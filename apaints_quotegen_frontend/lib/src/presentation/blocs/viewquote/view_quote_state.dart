abstract class ViewQuoteState {}

class ViewQuoteInitial extends ViewQuoteState {}

class ViewQuoteLoading extends ViewQuoteState {}

class ViewQuoteFailure extends ViewQuoteState {
  final String message;

  ViewQuoteFailure({required this.message});
}

class ViewQuoteLoaded extends ViewQuoteState {}
