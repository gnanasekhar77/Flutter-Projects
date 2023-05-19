import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/logger.dart';
import 'package:APaints_QGen/src/data/datasources/remote/flutter_toast_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/form_field_validator_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/data/models/email_template_model.dart';
import 'package:APaints_QGen/src/data/models/template_quote/template_quote_results_response.dart';
import 'package:APaints_QGen/src/data/repositories/email_template_repo.dart';
import 'package:APaints_QGen/src/presentation/blocs/email_template/email_template_event.dart';
import 'package:APaints_QGen/src/presentation/blocs/email_template/email_template_state.dart';
import 'package:bloc/bloc.dart';

class EmailTemplateBloc
    extends Bloc<GetEmailTemplateEvent, EmailTemplateState> {
  final emailTempRepo = getSingleton<EmailTemplateRepository>();
  final _validatorProvider = getSingleton<FormFieldValidatorProvider>();
  final _secureStorageProvider = getSingleton<SecureStorageProvider>();
  final _flutterToastProvider = getSingleton<FlutterToastProvider>();

  FormFieldValidatorProvider get validatorProvider => _validatorProvider;
  FlutterToastProvider get flutterToastProvider => _flutterToastProvider;

  EmailTemplateModel? templateQuoteListResponse;
  int? index;
  List<int>? itemIndex;
  bool loadingStatus = true;

  Future<void> getEmailTemplateList({
    required String? projectID,
    required String? quoteID,
    required String? email,
    required String? category,
    required String? total,
    required String? userName,
  }) async {
    add(
      GetEmailTemplateEvent(
          projectID: projectID,
          quoteID: quoteID,
          emailID: email,
          category: category,
          total: total,
          userName: userName),
    );
  }

  EmailTemplateBloc() : super(EmailTemplateInitial()) {
    on<GetEmailTemplateEvent>((event, emit) => getEmailTemplate(event, emit));
    // on<GetRefreshSkuEvent>((event, emit) => getRefreshSku(event, emit));
  }

  void getEmailTemplate(
      GetEmailTemplateEvent event, Emitter<EmailTemplateState> emit) async {
    emit(EmailTemplateLoading());
    try {
      EmailTemplateModel response = await emailTempRepo.sendEmailTemplateFuture(
          event.projectID,
          event.quoteID,
          event.emailID,
          event.category,
          event.total,
          event.userName);
      templateQuoteListResponse = response;
      logger("Response in Competition Bloc: $response");
      logger(templateQuoteListResponse!.status!);
      if (templateQuoteListResponse!.status! == '200') {
        logger("TOKEN: ${templateQuoteListResponse?.status ?? ''}");

        emit(EmailTemplateLoaded());
      } else {
        FlutterToastProvider()
            .show(message: templateQuoteListResponse!.status!);
        emit(EmailTemplateFailure(message: templateQuoteListResponse!.status!));
      }
    } catch (e, st) {
      logES(e, st);

      emit(EmailTemplateFailure(message: e.toString()));
    }
  }
}
