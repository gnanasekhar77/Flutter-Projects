import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/logger.dart';
import 'package:APaints_QGen/src/data/datasources/remote/api_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/flutter_toast_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/form_field_validator_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/data/models/copy_quote_response_model.dart';
import 'package:APaints_QGen/src/data/repositories/copy_quote_repo.dart';
import 'package:APaints_QGen/src/presentation/blocs/copy_quote/copy_quote_event.dart';
import 'package:APaints_QGen/src/presentation/blocs/copy_quote/copy_quote_state.dart';
import 'package:bloc/bloc.dart';

class CopyQuoteBloc extends Bloc<CopyQuoteEvent, CopyQuoteState> {
  final apiProvider = getSingleton<APIProvider>();
  final copyQuoteRepo = getSingleton<CopyQuoteRepository>();
  final _validatorProvider = getSingleton<FormFieldValidatorProvider>();
  final _secureStorageProvider = getSingleton<SecureStorageProvider>();
  final _flutterToastProvider = getSingleton<FlutterToastProvider>();

  FormFieldValidatorProvider get validatorProvider => _validatorProvider;
  FlutterToastProvider get flutterToastProvider => _flutterToastProvider;

  CopyQuoteResponse? copyQuoteResponse;
  int? index;
  List<int>? itemIndex;
  bool loadingStatus = true;

  Future<void> copyQuote({
    required String? projectID,
    required String? quoteID,
    required String? quoteName,
  }) async {
    add(
      GetCopyQuoteEvent(
        projectID: projectID,
        quoteID: quoteID,
        quoteName: quoteName,
      ),
    );
  }


  CopyQuoteBloc() : super(CopyQuoteInitial()) {
    on<GetCopyQuoteEvent>((event, emit) => getCopyQuote(event, emit));
  }

  void getCopyQuote(GetCopyQuoteEvent event, Emitter<CopyQuoteState> emit) async {
    emit(CopyQuoteLoading());
    try {
      CopyQuoteResponse response = await copyQuoteRepo.copyQuoteFuture(
         projectID: event.projectID,
         quoteID: event.quoteID,
         quoteName: event.quoteName);
      copyQuoteResponse = response;
      logger("Response in AuthBloc: $response");
      logger(copyQuoteResponse!.statusMessage!);
      if (copyQuoteResponse!.status! == '200') {
        logger("TOKEN: ${copyQuoteResponse?.status ?? ''}");
        // logger("Length: ${skuResponse!.data!.length}");
        // _setAuthenticationHeaders(getCategoriesModel);
        // await _secureStorageProvider.saveUserToDisk(userData!);
        await _secureStorageProvider.add(key: 'isLoggedIn', value: 'true');
        emit(CopyQuoteLoaded());
      } else {
        FlutterToastProvider().show(message: copyQuoteResponse!.statusMessage!);
        emit(CopyQuoteFailure(message: copyQuoteResponse!.statusMessage!));
      }
    } catch (e, st) {
      logES(e, st);

      emit(CopyQuoteFailure(message: e.toString()));
    }
  }

}
