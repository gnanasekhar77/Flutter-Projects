import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/logger.dart';
import 'package:APaints_QGen/src/data/datasources/remote/api_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/flutter_toast_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/form_field_validator_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/data/models/sku_response.dart';
import 'package:APaints_QGen/src/data/repositories/search_repo.dart';
import 'package:APaints_QGen/src/presentation/blocs/search/search_event.dart';
import 'package:APaints_QGen/src/presentation/blocs/search/search_state.dart';
import 'package:bloc/bloc.dart';

class ProjectSearchBloc extends Bloc<SearchEvent, SearchState> {
  final apiProvider = getSingleton<APIProvider>();
  SearchRepositoryImpl searchListRepo = getSingleton<SearchRepositoryImpl>();
  final _validatorProvider = getSingleton<FormFieldValidatorProvider>();
  final secureStorageProvider = getSingleton<SecureStorageProvider>();
  final _flutterToastProvider = getSingleton<FlutterToastProvider>();

  FormFieldValidatorProvider get validatorProvider => _validatorProvider;
  FlutterToastProvider get flutterToastProvider => _flutterToastProvider;

  List<SKUData>? searchResponseModel;
  int? index;
  List<int>? itemIndex;
  bool loadingStatus = true;

  Future<void> getSearch({required String searchItem}) async {
    add(
      Search(query: searchItem),
    );
  }

  ProjectSearchBloc({required this.searchListRepo})
      : super(SearchUninitialized()) {
    on<Search>((event, emit) => getSearchList(event, emit));
  }

  void getSearchList(Search event, Emitter<SearchState> emit) async {
    emit(SearchUninitialized());
    try {
      List<SKUData> response = await searchListRepo.searchLists(event.query);
      searchResponseModel = response;
      logger("Response in AuthBloc: $response");
      logger(searchResponseModel!.length);
      if (searchResponseModel!.isNotEmpty) {
        emit(SearchLoaded(searchResponseModel: searchResponseModel ?? []));
      }
    } catch (e, st) {
      logES(e, st);

      // emit(SearchFailure(message: e.toString()));
    }
  }
}
