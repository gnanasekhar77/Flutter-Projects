abstract class DeleteQuoteState {}

class DeleteQuoteStateInitial extends DeleteQuoteState {}

class DeleteQuoteStateLoading extends DeleteQuoteState {}

class DeleteQuoteStateFailure extends DeleteQuoteState {
  final String message;

  DeleteQuoteStateFailure({required this.message});
}

class DeleteQuoteStateLoaded extends DeleteQuoteState {}
