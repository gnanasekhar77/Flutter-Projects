abstract class TempQuoteSearchResultState {}

class TempQuoteSearchResultInitial extends TempQuoteSearchResultState {}

class TempQuoteSearchResultLoading extends TempQuoteSearchResultState {}

class TempQuoteSearchResultFailure extends TempQuoteSearchResultState {
  final String message;

  TempQuoteSearchResultFailure({required this.message});
}

class TempQuoteSearchResultLoaded extends TempQuoteSearchResultState {}

