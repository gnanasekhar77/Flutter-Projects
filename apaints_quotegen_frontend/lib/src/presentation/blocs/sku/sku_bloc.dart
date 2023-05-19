import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/logger.dart';
import 'package:APaints_QGen/src/data/datasources/remote/api_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/flutter_toast_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/form_field_validator_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/data/models/sku_response.dart';
import 'package:APaints_QGen/src/data/repositories/sku_repo.dart';
import 'package:APaints_QGen/src/presentation/blocs/sku/sku_event.dart';
import 'package:APaints_QGen/src/presentation/blocs/sku/sku_state.dart';
import 'package:bloc/bloc.dart';

class SkuListBloc extends Bloc<SkuEvent, SkuState> {
  final _apiProvider = getSingleton<APIProvider>();
  final skuRepo = getSingleton<GetSkuRepository>();
  final _validatorProvider = getSingleton<FormFieldValidatorProvider>();
  final _secureStorageProvider = getSingleton<SecureStorageProvider>();
  final _flutterToastProvider = getSingleton<FlutterToastProvider>();

  FormFieldValidatorProvider get validatorProvider => _validatorProvider;
  FlutterToastProvider get flutterToastProvider => _flutterToastProvider;

  SKUResponse? skuResponse;
  int? index;
  List<int>? itemIndex;
  bool loadingStatus = true;

  Future<void> getSkuList({
    required String? category,
    required String? brand,
    required String? range,
    required String? area,
    required int limit,
  }) async {
    add(
      GetSkuEvent(
        category: category,
        brand: brand,
        range: range,
        area: area,
        limit: limit,
      ),
    );
  }

  SkuListBloc() : super(SkuInitial()) {
    on<GetSkuEvent>((event, emit) => getSku(event, emit));
  }

  void getSku(GetSkuEvent event, Emitter<SkuState> emit) async {
    emit(SkuLoading());
    try {
      SKUResponse response = await skuRepo.skuFuture(
          category: event.category,
          brand: event.brand,
          range: event.range,
          area: event.area,
          limit: event.limit);
      skuResponse = response;
      if (skuResponse!.status! == '200') {
        logger("TOKEN: ${skuResponse?.status ?? ''}");
        logger("Length: ${skuResponse!.data!.length}");

        await _secureStorageProvider.add(key: 'isLoggedIn', value: 'true');
        emit(SkuLoaded());
      } else {
        FlutterToastProvider().show(message: skuResponse!.statusMessage!);
        emit(SkuFailure(message: skuResponse!.statusMessage!));
      }
    } catch (e, st) {
      logES(e, st);

      emit(SkuFailure(message: e.toString()));
    }
  }

  // getRefreshSku(GetRefreshSkuEvent event, Emitter<SkuState> emit) async* {
  //   emit(SkuLoading());
  //   try {
  //     SKUResponse response = await skuRepo.skuFuture(
  //         category: event.category,
  //         brand: event.brand,
  //         range: event.range,
  //         area: event.area,
  //         limit: event.limit);
  //     skuResponse = response;
  //     logger("Response in AuthBloc: $response");
  //     logger(skuResponse!.statusMessage!);
  //     if (skuResponse!.status! == '200') {
  //       logger("TOKEN: ${skuResponse?.status ?? ''}");
  //       logger("Length: ${skuResponse!.data!.length}");
  //       // _setAuthenticationHeaders(getCategoriesModel);
  //       // await _secureStorageProvider.saveUserToDisk(userData!);
  //       await _secureStorageProvider.add(key: 'isLoggedIn', value: 'true');
  //       emit(SkuReLoaded());
  //       // emit(SkuInitial(/))
  //       yield (SkuReLoaded);
  //     } else {
  //       FlutterToastProvider().show(message: skuResponse!.statusMessage!);
  //       emit(SkuFailure(message: skuResponse!.statusMessage!));
  //     }
  //   } catch (e, st) {
  //     logES(e, st);

  //     emit(SkuFailure(message: e.toString()));
  //   }
  // }
}
