abstract class CreateQuoteState {}

class CreateQuoteInitial extends CreateQuoteState {}

class CreateQuoteLoading extends CreateQuoteState {}

class CreateQuoteFailure extends CreateQuoteState {
  final String message;

  CreateQuoteFailure({required this.message});
}

class CreateQuoteLoaded extends CreateQuoteState {}

class CreateProjectInitial extends CreateQuoteState {}

class CreateProjectLoading extends CreateQuoteState {}

class CreateProjectFailure extends CreateQuoteState {
  final String message;

  CreateProjectFailure({required this.message});
}

class CreateProjectLoaded extends CreateQuoteState {}
