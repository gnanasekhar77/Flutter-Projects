import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/logger.dart';
import 'package:APaints_QGen/src/data/datasources/remote/flutter_toast_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/form_field_validator_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/data/models/competition_search/competition_search_list_response.dart';
import 'package:APaints_QGen/src/data/repositories/competition_search_list_repo.dart';
import 'package:APaints_QGen/src/presentation/blocs/competition_search/search_list/competition_search_list_event.dart';
import 'package:APaints_QGen/src/presentation/blocs/competition_search/search_list/competition_search_list_state.dart';
import 'package:bloc/bloc.dart';

class GetCompetitionSearchListBloc
    extends Bloc<CompetitionSearchListEvent, CompetitionSearchListState> {
  final competitionListRepo = getSingleton<CompetitionSearchListRepository>();
  final _validatorProvider = getSingleton<FormFieldValidatorProvider>();
  final _secureStorageProvider = getSingleton<SecureStorageProvider>();
  final _flutterToastProvider = getSingleton<FlutterToastProvider>();

  FormFieldValidatorProvider get validatorProvider => _validatorProvider;
  FlutterToastProvider get flutterToastProvider => _flutterToastProvider;

  CompetitionSearchListResponse? competitionSearchListResponse;
  int? index;
  List<int>? itemIndex;
  bool loadingStatus = true;

  Future<void> getCompetitionSearchList({required String? token}) async {
    add(
      GetCompetitionSearchListEvent(token: token),
    );
  }

  GetCompetitionSearchListBloc() : super(CompetitionSearchListInitial()) {
    on<GetCompetitionSearchListEvent>(
        (event, emit) => getCompSearchList(event, emit));
    // on<GetRefreshSkuEvent>((event, emit) => getRefreshSku(event, emit));
  }

  void getCompSearchList(GetCompetitionSearchListEvent event,
      Emitter<CompetitionSearchListState> emit) async {
    emit(CompetitionSearchListLoading());
    try {
      CompetitionSearchListResponse response =
          await competitionListRepo.competitionSearchListFuture();
      competitionSearchListResponse = response;
      logger("Response in Competition Bloc: $response");
      logger(competitionSearchListResponse!.statusMessage!);
      if (competitionSearchListResponse!.status! == '200') {
        logger("TOKEN: ${competitionSearchListResponse?.status ?? ''}");
        logger("Length: ${competitionSearchListResponse!.data!.length}");
        // _setAuthenticationHeaders(getCategoriesModel);
        // await _secureStorageProvider.saveUserToDisk(userData!);
        await _secureStorageProvider.add(key: 'isLoggedIn', value: 'true');
        emit(CompetitionSearchListLoaded());
      } else {
        FlutterToastProvider()
            .show(message: competitionSearchListResponse!.statusMessage!);
        emit(CompetitionSearchListFailure(
            message: competitionSearchListResponse!.statusMessage!));
      }
    } catch (e, st) {
      logES(e, st);

      emit(CompetitionSearchListFailure(message: e.toString()));
    }
  }
}
