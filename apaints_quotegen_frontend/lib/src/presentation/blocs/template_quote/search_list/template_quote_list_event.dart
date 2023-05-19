abstract class TemplateQuoteListEvent {}

class GetTemplateQuoteListEvent extends TemplateQuoteListEvent {
  final String? token;

  @override
  GetTemplateQuoteListEvent(
      {required this.token});
}
