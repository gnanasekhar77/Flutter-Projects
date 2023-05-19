import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/logger.dart';
import 'package:APaints_QGen/src/data/datasources/remote/api_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/flutter_toast_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/form_field_validator_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/data/models/categories_model.dart';
import 'package:APaints_QGen/src/data/repositories/categories_repo.dart';
import 'package:APaints_QGen/src/presentation/blocs/categories/categories_event.dart';
import 'package:APaints_QGen/src/presentation/blocs/categories/categories_state.dart';
import 'package:bloc/bloc.dart';

class CategoriesListBloc extends Bloc<CategoriesEvent, CategoriesState> {
  final _apiProvider = getSingleton<APIProvider>();
  final categoriesRepo = getSingleton<GetCategoriesRepository>();
  final _validatorProvider = getSingleton<FormFieldValidatorProvider>();
  final _secureStorageProvider = getSingleton<SecureStorageProvider>();
  final _flutterToastProvider = getSingleton<FlutterToastProvider>();

  FormFieldValidatorProvider get validatorProvider => _validatorProvider;
  FlutterToastProvider get flutterToastProvider => _flutterToastProvider;

  GetCategoriesModel? getCategoriesModel;
  int? index;
  List<int>? itemIndex;
  bool loadingStatus = true;

  Future<void> getCategories() async {
    add(
      GetCategoriesEvent(),
    );
  }

  CategoriesListBloc() : super(CategoriesInitial()) {
    on<GetCategoriesEvent>((event, emit) => _getCategories(event, emit));
  }

  void _getCategories(
      GetCategoriesEvent event, Emitter<CategoriesState> emit) async {
    emit(CategoriesLoading());
    try {
      GetCategoriesModel response = await categoriesRepo.getCategoriesFuture();
      getCategoriesModel = response;
      logger("Response in AuthBloc: $response");
      logger(getCategoriesModel!.statusMessage!);
      if (getCategoriesModel!.status! == '200') {
        logger("TOKEN: ${getCategoriesModel?.status ?? ''}");
        logger("Length: ${getCategoriesModel!.data!.length}");
        logger("Category Image: ${getCategoriesModel!.data![0].categoryImage}");
        // _setAuthenticationHeaders(getCategoriesModel);
        // await _secureStorageProvider.saveUserToDisk(userData!);
        await _secureStorageProvider.add(key: 'isLoggedIn', value: 'true');
        emit(CategoriesLoaded());
      } else {
        FlutterToastProvider()
            .show(message: getCategoriesModel!.statusMessage!);
        emit(CategoriesFailure(message: getCategoriesModel!.statusMessage!));
      }
    } catch (e, st) {
      logES(e, st);

      emit(CategoriesFailure(message: e.toString()));
    }
  }
}
