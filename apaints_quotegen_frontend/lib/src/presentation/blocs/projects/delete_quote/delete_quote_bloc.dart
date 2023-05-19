import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/logger.dart';
import 'package:APaints_QGen/src/data/datasources/remote/flutter_toast_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/form_field_validator_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/data/models/delete_quote_response.dart';
import 'package:APaints_QGen/src/data/repositories/delete_quote_repo.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/delete_quote/delete_quote_event.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/delete_quote/delete_quote_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DelQuoteBloc extends Bloc<DelQuoteEvent, DeleteQuoteState> {
  final deleteProjectRepo = getSingleton<DeleteQuoteRepository>();
  final _validatorProvider = getSingleton<FormFieldValidatorProvider>();
  final _secureStorageProvider = getSingleton<SecureStorageProvider>();
  final _flutterToastProvider = getSingleton<FlutterToastProvider>();

  FormFieldValidatorProvider get validatorProvider => _validatorProvider;
  FlutterToastProvider get flutterToastProvider => _flutterToastProvider;

  DeleteQuoteResponse? deleteQuoteResponse;
  int? index;
  List<int>? itemIndex;
  bool loadingStatus = true;

  Future<void> deleteQuote({
    required String? projectID,
    required String? quoteID,
  }) async {
    add(
      DelQuoteEvent(projectID: projectID, quoteID: quoteID),
    );
  }

  DelQuoteBloc() : super(DeleteQuoteStateInitial()) {
    on<DelQuoteEvent>((event, emit) => deleteProject(event, emit));
  }

  void deleteProject(
      DelQuoteEvent event, Emitter<DeleteQuoteState> emit) async {
    emit(DeleteQuoteStateLoading());
    try {
      DeleteQuoteResponse response = await deleteProjectRepo.deleteQuoteFuture(
        projectID: event.projectID,
        quoteID: event.quoteID,
      );
      deleteQuoteResponse = response;
      logger("Response in AuthBloc: $response");
      logger(deleteQuoteResponse?.statusMessage??'');
      if (deleteQuoteResponse?.status == '200') {
        logger(
            "TOKEN: ${deleteQuoteResponse?.status ?? ''}");
        await _secureStorageProvider.add(key: 'isLoggedIn', value: 'true');
        emit(DeleteQuoteStateLoaded());
      } else {
        // FlutterToastProvider().show(
        //     message: createQuoteToExistingProjectResponseModel!.statusMessage!);
        emit(DeleteQuoteStateFailure(
            message:
                deleteQuoteResponse!.statusMessage!));
      }
    } catch (e, st) {
      logES(e, st);

      emit(DeleteQuoteStateFailure(message: e.toString()));
    }
  }
}
