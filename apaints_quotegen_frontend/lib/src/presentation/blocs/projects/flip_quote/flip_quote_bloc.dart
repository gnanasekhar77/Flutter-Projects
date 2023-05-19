import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/logger.dart';
import 'package:APaints_QGen/src/data/datasources/remote/flutter_toast_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/form_field_validator_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/data/models/flip_quote_response_model.dart';
import 'package:APaints_QGen/src/data/repositories/flip_quote_repo.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/flip_quote/flip_quote_event.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/flip_quote/flip_quote_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FlipQuoteBloc extends Bloc<FlipQuoteEvent, FlipQuoteState> {
  final flipQuoteRepo = getSingleton<FlipQuoteRepository>();
  final _validatorProvider = getSingleton<FormFieldValidatorProvider>();
  final _secureStorageProvider = getSingleton<SecureStorageProvider>();
  final _flutterToastProvider = getSingleton<FlutterToastProvider>();

  FormFieldValidatorProvider get validatorProvider => _validatorProvider;
  FlutterToastProvider get flutterToastProvider => _flutterToastProvider;

  FlipQuoteResponseModel? responseModel;
  int? index;
  List<int>? itemIndex;
  bool loadingStatus = true;

  Future<void> flipQuote(
      {required String? projectID,
      required String? quoteID,
      required String? currentRange,
      required String? selectedRange,
      required String? createdType,
      required bool? areYouSure,
      required String? quoteName
      }) async {
    add(
      FlipQuoteEvent(
        projectID: projectID,
        quoteID: quoteID,
        currentRange: currentRange,
        selectedRange: selectedRange,
        createdType: createdType,
        areyousure: areYouSure,
        quoteName: quoteName
      ),
    );
  }

  FlipQuoteBloc() : super(FlipQuoteInitial()) {
    on<FlipQuoteEvent>((event, emit) => _flipQuote(event, emit));
  }

  void _flipQuote(FlipQuoteEvent event, Emitter<FlipQuoteState> emit) async {
    emit(FlipQuoteLoading());
    try {
      FlipQuoteResponseModel response = await flipQuoteRepo.flipQuoteFuture(
        projectid: event.projectID,
        quoteID: event.quoteID,
        currentRange: event.currentRange,
        selectedRange: event.selectedRange,
        createdType: event.createdType,
        areYouSure: event.areyousure,
        quoteName: event.quoteName

      );
      responseModel = response;
      logger("Response in AuthBloc: $responseModel");
      logger(responseModel!.statusMessage ?? '');
      if (responseModel!.status == '200') {
        logger("TOKEN: ${response.status ?? ''}");
        // responseModel!.matchedStatus ?? true
        //     ? null
        //     : FlutterToastProvider().show(message: responseModel!.matchedtext ?? '');
        // logger("Category Image: ${getProjectsResponseModel!.data![0].pROJECTNAME}");
        // _setAuthenticationHeaders(getCategoriesModel);
        // await _secureStorageProvider.saveUserToDisk(userData!);
        await _secureStorageProvider.add(key: 'isLoggedIn', value: 'true');
        emit(FlipQuoteLoaded());
      } else {
        FlutterToastProvider().show(message: responseModel!.statusMessage!);
        emit(FlipQuoteFailure(message: responseModel!.statusMessage!));
      }
    } catch (e, st) {
      logES(e, st);

      emit(FlipQuoteFailure(message: e.toString()));
    }
  }
}
