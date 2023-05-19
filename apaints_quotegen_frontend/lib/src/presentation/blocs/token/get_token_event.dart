abstract class TokenEvent {}

class GetTokenEvent extends TokenEvent {
  final String? token;

  @override
  GetTokenEvent({
    this.token,
  });
}
