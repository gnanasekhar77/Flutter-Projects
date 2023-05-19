abstract class TokenState {}

class TokenInitial extends TokenState {}

class TokenLoading extends TokenState {}

class TokenFailure extends TokenState {
  final String message;

  TokenFailure({required this.message});
}

class TokenLoaded extends TokenState {}
