import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/logger.dart';
import 'package:APaints_QGen/src/data/datasources/remote/flutter_toast_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/form_field_validator_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/data/models/competition_search/competition_search_result_response.dart';
import 'package:APaints_QGen/src/data/models/competition_search_san_bund_response.dart';
import 'package:APaints_QGen/src/data/repositories/competition_search_result_repo.dart';
import 'package:APaints_QGen/src/data/repositories/competition_search_san_bund_repo.dart';
import 'package:APaints_QGen/src/presentation/blocs/competition_search/bundle_sanware_list/competition_search_san_bund_event.dart';
import 'package:APaints_QGen/src/presentation/blocs/competition_search/bundle_sanware_list/competition_search_san_bund_state.dart';
import 'package:APaints_QGen/src/presentation/blocs/competition_search/search_result/competition_search_result_event.dart';
import 'package:APaints_QGen/src/presentation/blocs/competition_search/search_result/competition_search_result_state.dart';
import 'package:bloc/bloc.dart';

class GetCompetitionSanBundResultBloc
    extends Bloc<CompetitionSearchSanBundEvent, CompetitionSearchSanBundState> {
  final competitionSanBundRepo = getSingleton<CompetitionSearchSanBundRepository>();
  final _validatorProvider = getSingleton<FormFieldValidatorProvider>();
  final _secureStorageProvider = getSingleton<SecureStorageProvider>();
  final _flutterToastProvider = getSingleton<FlutterToastProvider>();

  FormFieldValidatorProvider get validatorProvider => _validatorProvider;
  FlutterToastProvider get flutterToastProvider => _flutterToastProvider;

  CompetitionSearchSanBundResponse? competitionSearchSanBundResponse;
  int? index;
  List<int>? itemIndex;
  bool loadingStatus = true;

  Future<void> getCompetitionSanBundList(
      {required String? range,
      required String? bundle,
      required String? sanware}) async {
    add(
      GetCompetitionSearchSanBundEvent(
          range: range, bundle: bundle, sanware: sanware),
    );
  }

  GetCompetitionSanBundResultBloc() : super(CompetitionSearchSanBundInitial()) {
    on<GetCompetitionSearchSanBundEvent>(
        (event, emit) => getCompSearchSanBundResults(event, emit));
  }

  void getCompSearchSanBundResults(GetCompetitionSearchSanBundEvent event,
      Emitter<CompetitionSearchSanBundState> emit) async {
    emit(CompetitionSearchSanBundLoading());
    try {
      CompetitionSearchSanBundResponse response =
          await competitionSanBundRepo.competitionSearchSanBundFuture(
              event.range, event.bundle, event.sanware);
      competitionSearchSanBundResponse = response;
      logger("Response in Competition Bloc: $response");
      logger(competitionSearchSanBundResponse!.statusMessage!);
      if (competitionSearchSanBundResponse!.status! == '200') {
        logger("TOKEN: ${competitionSearchSanBundResponse?.status ?? ''}");
        // logger("Length: ${competitionSearchSanBundResponse!.data!.length}");
        // _setAuthenticationHeaders(getCategoriesModel);
        // await _secureStorageProvider.saveUserToDisk(userData!);
        await _secureStorageProvider.add(key: 'isLoggedIn', value: 'true');
        // if ((competitionSearchSanBundResponse!.data ?? []).isEmpty) {
        //   FlutterToastProvider().show(message: 'No data found');
        // }
        emit(CompetitionSearchSanBundLoaded());
      } else {
        FlutterToastProvider()
            .show(message: competitionSearchSanBundResponse!.statusMessage!);
        emit(CompetitionSearchSanBundFailure(
            message: competitionSearchSanBundResponse!.statusMessage!));
      }
    } catch (e, st) {
      logES(e, st);

      emit(CompetitionSearchSanBundFailure(message: e.toString()));
    }
  }
}
