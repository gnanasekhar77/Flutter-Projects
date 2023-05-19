import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/logger.dart';
import 'package:APaints_QGen/src/data/datasources/remote/flutter_toast_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/form_field_validator_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/data/models/template_quote/template_quote_list_response.dart';
import 'package:APaints_QGen/src/data/repositories/template_quote_list_repo.dart';
import 'package:APaints_QGen/src/presentation/blocs/template_quote/search_list/template_quote_list_event.dart';
import 'package:APaints_QGen/src/presentation/blocs/template_quote/search_list/template_quote_list_state.dart';
import 'package:bloc/bloc.dart';

class TemplateQuoteListBloc
    extends Bloc<GetTemplateQuoteListEvent, TemplateQuoteListState> {
  final competitionListRepo = getSingleton<TemplateQuoteListRepository>();
  final _validatorProvider = getSingleton<FormFieldValidatorProvider>();
  final _secureStorageProvider = getSingleton<SecureStorageProvider>();
  final _flutterToastProvider = getSingleton<FlutterToastProvider>();

  FormFieldValidatorProvider get validatorProvider => _validatorProvider;
  FlutterToastProvider get flutterToastProvider => _flutterToastProvider;

  TemplateQuoteListResponse? templateQuoteListResponse;
  int? index;
  List<int>? itemIndex;
  bool loadingStatus = true;

  Future<void> getTemplateQuoteList({required String? token}) async {
    add(
      GetTemplateQuoteListEvent(token: token),
    );
  }

  TemplateQuoteListBloc() : super(TemplateQuoteListInitial()) {
    on<GetTemplateQuoteListEvent>(
        (event, emit) => getTempQuoteSearchList(event, emit));
    // on<GetRefreshSkuEvent>((event, emit) => getRefreshSku(event, emit));
  }

  void getTempQuoteSearchList(GetTemplateQuoteListEvent event,
      Emitter<TemplateQuoteListState> emit) async {
    emit(TemplateQuoteListLoading());
    try {
      TemplateQuoteListResponse response =
          await competitionListRepo.templateQuoteListFuture();
      templateQuoteListResponse = response;
      logger("Response in Competition Bloc: $response");
      logger(templateQuoteListResponse!.statusMessage!);
      if (templateQuoteListResponse!.success! == '200') {
        logger("TOKEN: ${templateQuoteListResponse?.success ?? ''}");
        logger("Length: ${templateQuoteListResponse!.data!.length}");
        // _setAuthenticationHeaders(getCategoriesModel);
        // await _secureStorageProvider.saveUserToDisk(userData!);
        await _secureStorageProvider.add(key: 'isLoggedIn', value: 'true');
        if ((templateQuoteListResponse!.data ?? []).isEmpty) {
          FlutterToastProvider().show(message: 'No Data found');
        }
        emit(TemplateQuoteListLoaded());
      } else {
        FlutterToastProvider()
            .show(message: templateQuoteListResponse!.statusMessage!);
        emit(TemplateQuoteListFailure(
            message: templateQuoteListResponse!.statusMessage!));
      }
    } catch (e, st) {
      logES(e, st);

      emit(TemplateQuoteListFailure(message: e.toString()));
    }
  }
}
