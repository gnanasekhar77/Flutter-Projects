abstract class TemplateQuoteListState {}

class TemplateQuoteListInitial extends TemplateQuoteListState {}

class TemplateQuoteListLoading extends TemplateQuoteListState {}

class TemplateQuoteListFailure extends TemplateQuoteListState {
  final String message;

  TemplateQuoteListFailure({required this.message});
}

class TemplateQuoteListLoaded extends TemplateQuoteListState {}

