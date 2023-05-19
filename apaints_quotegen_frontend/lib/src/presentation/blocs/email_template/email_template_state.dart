abstract class EmailTemplateState {}

class EmailTemplateInitial extends EmailTemplateState {}

class EmailTemplateLoading extends EmailTemplateState {}

class EmailTemplateFailure extends EmailTemplateState {
  final String message;

  EmailTemplateFailure({required this.message});
}

class EmailTemplateLoaded extends EmailTemplateState {}

