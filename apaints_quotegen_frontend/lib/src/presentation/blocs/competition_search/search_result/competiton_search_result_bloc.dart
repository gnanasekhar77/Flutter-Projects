import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/logger.dart';
import 'package:APaints_QGen/src/data/datasources/remote/flutter_toast_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/form_field_validator_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/data/models/competition_search/competition_search_result_response.dart';
import 'package:APaints_QGen/src/data/repositories/competition_search_result_repo.dart';
import 'package:APaints_QGen/src/presentation/blocs/competition_search/search_result/competition_search_result_event.dart';
import 'package:APaints_QGen/src/presentation/blocs/competition_search/search_result/competition_search_result_state.dart';
import 'package:bloc/bloc.dart';

class GetCompetitionSearchResultBloc
    extends Bloc<CompetitionSearchResultEvent, CompetitionSearchResultState> {
  final competitionListRepo = getSingleton<CompetitionSearchResultRepository>();
  final _validatorProvider = getSingleton<FormFieldValidatorProvider>();
  final _secureStorageProvider = getSingleton<SecureStorageProvider>();
  final _flutterToastProvider = getSingleton<FlutterToastProvider>();

  FormFieldValidatorProvider get validatorProvider => _validatorProvider;
  FlutterToastProvider get flutterToastProvider => _flutterToastProvider;

  CompetitionSearchResultResponse? competitionSearchResultResponse;
  int? index;
  List<int>? itemIndex;
  bool loadingStatus = true;

  Future<void> getCompetitionSearchList(
      {required String? brandName,
      required String? rangeName,
      required String? skuName}) async {
    add(
      GetCompetitionSearchResultEvent(
          brandName: brandName, rangeName: rangeName, skuName: skuName),
    );
  }

  GetCompetitionSearchResultBloc() : super(CompetitionSearchResultInitial()) {
    on<GetCompetitionSearchResultEvent>(
        (event, emit) => getCompSearchResults(event, emit));
  }

  void getCompSearchResults(GetCompetitionSearchResultEvent event,
      Emitter<CompetitionSearchResultState> emit) async {
    emit(CompetitionSearchResultLoading());
    try {
      CompetitionSearchResultResponse response =
          await competitionListRepo.competitionSearchResultFuture(
              event.brandName, event.rangeName, event.skuName);
      competitionSearchResultResponse = response;
      logger("Response in Competition Bloc: $response");
      logger(competitionSearchResultResponse!.statusMessage!);
      if (competitionSearchResultResponse!.status! == '200') {
        logger("TOKEN: ${competitionSearchResultResponse?.status ?? ''}");
        logger("Length: ${competitionSearchResultResponse!.data!.length}");
        // _setAuthenticationHeaders(getCategoriesModel);
        // await _secureStorageProvider.saveUserToDisk(userData!);
        await _secureStorageProvider.add(key: 'isLoggedIn', value: 'true');
        if ((competitionSearchResultResponse!.data ?? []).isEmpty) {
          FlutterToastProvider().show(message: 'No data found');
        }
        emit(CompetitionSearchResultLoaded());
      } else {
        FlutterToastProvider()
            .show(message: competitionSearchResultResponse!.statusMessage!);
        emit(CompetitionSearchResultFailure(
            message: competitionSearchResultResponse!.statusMessage!));
      }
    } catch (e, st) {
      logES(e, st);

      emit(CompetitionSearchResultFailure(message: e.toString()));
    }
  }
}
