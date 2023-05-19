abstract class FlipQuoteState {}

class FlipQuoteInitial extends FlipQuoteState {}

class FlipQuoteLoading extends FlipQuoteState {}

class FlipQuoteFailure extends FlipQuoteState {
  final String message;

  FlipQuoteFailure({required this.message});
}

class FlipQuoteLoaded extends FlipQuoteState {}
