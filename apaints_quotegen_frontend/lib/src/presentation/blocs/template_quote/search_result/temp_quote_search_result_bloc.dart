import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/logger.dart';
import 'package:APaints_QGen/src/data/datasources/remote/flutter_toast_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/form_field_validator_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/data/models/template_quote/template_quote_results_response.dart';
import 'package:APaints_QGen/src/data/repositories/temp_quote_search_result_repo.dart';
import 'package:APaints_QGen/src/presentation/blocs/template_quote/search_result/temp_quote_search_result_event.dart';
import 'package:APaints_QGen/src/presentation/blocs/template_quote/search_result/temp_quote_search_result_state.dart';
import 'package:bloc/bloc.dart';

class GetTempQuoteSearchResultBloc
    extends Bloc<TempQuoteSearchResultEvent, TempQuoteSearchResultState> {
  final competitionListRepo = getSingleton<TempQuoteSearchResultRepository>();
  final _validatorProvider = getSingleton<FormFieldValidatorProvider>();
  final _secureStorageProvider = getSingleton<SecureStorageProvider>();
  final _flutterToastProvider = getSingleton<FlutterToastProvider>();

  FormFieldValidatorProvider get validatorProvider => _validatorProvider;
  FlutterToastProvider get flutterToastProvider => _flutterToastProvider;

  TemplateQuoteResultsListResponse? templateQuoteResultsListResponse;
  int? index;
  List<int>? itemIndex;
  bool loadingStatus = true;

  Future<void> getTempQuoteSearchList(
      {required String? brandName,
      required String? rangeName,
      required String? bundleType,
      required String? sanwareType}) async {
    add(
      GetTempQuoteSearchResultEvent(
        brandName: brandName,
        rangeName: rangeName,
        bundleType: bundleType,
        sanwareType: sanwareType,
      ),
    );
  }

  GetTempQuoteSearchResultBloc() : super(TempQuoteSearchResultInitial()) {
    on<GetTempQuoteSearchResultEvent>(
        (event, emit) => getTempQuoteSearchResults(event, emit));
  }

  void getTempQuoteSearchResults(GetTempQuoteSearchResultEvent event,
      Emitter<TempQuoteSearchResultState> emit) async {
    emit(TempQuoteSearchResultLoading());
    try {
      TemplateQuoteResultsListResponse response = await competitionListRepo
          .tempQuoteSearchResultFuture(event.brandName, event.rangeName, event.bundleType, event.sanwareType);
      templateQuoteResultsListResponse = response;
      logger("Response in Competition Bloc: $response");
      logger(templateQuoteResultsListResponse!.statusMessage!);
      if (templateQuoteResultsListResponse!.status! == '200') {
        logger("TOKEN: ${templateQuoteResultsListResponse?.status ?? ''}");
        logger("Length: ${templateQuoteResultsListResponse!.data!.length}");
        // _setAuthenticationHeaders(getCategoriesModel);
        // await _secureStorageProvider.saveUserToDisk(userData!);
        await _secureStorageProvider.add(key: 'isLoggedIn', value: 'true');
        emit(TempQuoteSearchResultLoaded());
      } else {
        FlutterToastProvider()
            .show(message: templateQuoteResultsListResponse!.statusMessage!);
        emit(TempQuoteSearchResultFailure(
            message: templateQuoteResultsListResponse!.statusMessage!));
      }
    } catch (e, st) {
      logES(e, st);

      emit(TempQuoteSearchResultFailure(message: e.toString()));
    }
  }
}
