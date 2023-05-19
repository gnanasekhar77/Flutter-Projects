import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/logger.dart';
import 'package:APaints_QGen/src/data/datasources/remote/flutter_toast_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/form_field_validator_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/data/models/delete_quote_response.dart';
import 'package:APaints_QGen/src/data/repositories/delete_sku_repo.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/delete_sku_from_quote/delete_sku_event.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/delete_sku_from_quote/delete_sku_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DelSkuBloc extends Bloc<DelSkuEvent, DeleteSkuState> {
  final deleteSkuRepo = getSingleton<DeleteSkuRepository>();
  final _validatorProvider = getSingleton<FormFieldValidatorProvider>();
  final _secureStorageProvider = getSingleton<SecureStorageProvider>();
  final _flutterToastProvider = getSingleton<FlutterToastProvider>();

  FormFieldValidatorProvider get validatorProvider => _validatorProvider;
  FlutterToastProvider get flutterToastProvider => _flutterToastProvider;

  DeleteQuoteResponse? deleteQuoteResponse;
  int? index;
  List<int>? itemIndex;
  bool loadingStatus = true;

  Future<void> deleteSku({
    
    required String? quoteID,
    required String? skuID,
  }) async {
    add(
      DelSkuEvent( quoteID: quoteID, skuID: skuID),
    );
  }

  DelSkuBloc() : super(DeleteSkuStateInitial()) {
    on<DelSkuEvent>((event, emit) => deleteSkus(event, emit));
  }

  void deleteSkus(
      DelSkuEvent event, Emitter<DeleteSkuState> emit) async {
    emit(DeleteSkuStateLoading());
    try {
      DeleteQuoteResponse response = await deleteSkuRepo.deleteSkuFuture(
        
        quoteID: event.quoteID,
        skuID: event.skuID
      );
      deleteQuoteResponse = response;
      logger("Response in AuthBloc: $response");
      logger(deleteQuoteResponse?.statusMessage??'');
      if (deleteQuoteResponse?.status == '200') {
        logger(
            "TOKEN: ${deleteQuoteResponse?.status ?? ''}");
        await _secureStorageProvider.add(key: 'isLoggedIn', value: 'true');
        emit(DeleteSkuStateLoaded());
      } else {
        // FlutterToastProvider().show(
        //     message: createQuoteToExistingProjectResponseModel!.statusMessage!);
        emit(DeleteSkuStateFailure(
            message:
                deleteQuoteResponse!.statusMessage!));
      }
    } catch (e, st) {
      logES(e, st);

      emit(DeleteSkuStateFailure(message: e.toString()));
    }
  }
}
