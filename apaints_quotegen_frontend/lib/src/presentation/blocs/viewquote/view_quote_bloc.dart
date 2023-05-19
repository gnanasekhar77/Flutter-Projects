import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/logger.dart';
import 'package:APaints_QGen/src/data/datasources/remote/api_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/flutter_toast_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/form_field_validator_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/data/models/sku_request_model.dart';
import 'package:APaints_QGen/src/data/models/view_quote_response.dart';
import 'package:APaints_QGen/src/data/repositories/view_quote_repo.dart';
import 'package:APaints_QGen/src/presentation/blocs/viewquote/view_quote_event.dart';
import 'package:APaints_QGen/src/presentation/blocs/viewquote/view_quote_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ViewQuoteBloc extends Bloc<GetViewQuoteEvent, ViewQuoteState> {
  final _apiProvider = getSingleton<APIProvider>();
  final viewQuoteRepo = getSingleton<ViewQuoteRepository>();
  final _validatorProvider = getSingleton<FormFieldValidatorProvider>();
  final _secureStorageProvider = getSingleton<SecureStorageProvider>();
  final _flutterToastProvider = getSingleton<FlutterToastProvider>();

  FormFieldValidatorProvider get validatorProvider => _validatorProvider;
  FlutterToastProvider get flutterToastProvider => _flutterToastProvider;

  ViewQuoteResponse? viewResponse;
  int? index;
  List<int>? itemIndex;
  bool loadingStatus = true;

  Future<void> getViewQuoteList({
    required final List<Quoteinfo>? quoteInfo,
    required final String? discountAmount,
    required final String? totalPriceWithGst,
    required final String? quoteName,
    required final String? projectID,
    required final String? quoteType,
    required final bool isExist,
    required final String? projectName,
    required final String? contactPerson,
    required final String? mobileNumber,
    required final String? siteAddress,
    required final String? noOfBathrooms,
  }) async {
    add(GetViewQuoteEvent(
      quoteInfo: quoteInfo,
      discountAmount: discountAmount,
      totalPriceWithGst: totalPriceWithGst,
      quoteName: quoteName,
      projectID: projectID,
      quoteType: quoteType,
      isExist: isExist,
      projectName: projectName,
      contactPerson: contactPerson,
      mobileNumber: mobileNumber,
      siteAddress: siteAddress,
      noOfBathrooms: noOfBathrooms,
    ));
  }

  ViewQuoteBloc() : super(ViewQuoteInitial()) {
    on<GetViewQuoteEvent>((event, emit) => getSku(event, emit));
  }

  void getSku(GetViewQuoteEvent event, Emitter<ViewQuoteState> emit) async {
    emit(ViewQuoteLoading());
    try {
      ViewQuoteResponse response = await viewQuoteRepo.viewQuoteFuture(
        quoteInfo: event.quoteInfo,
        discountAmount: event.discountAmount,
        totalpricewithgst: event.totalPriceWithGst,
        quotename: event.quoteName,
        projectid: event.projectID,
        quotetype: event.quoteType,
        isExist: event.isExist,
        projectName: event.projectName,
        contactPerson: event.contactPerson,
        mobileNumber: event.mobileNumber,
        siteAddress: event.siteAddress,
        noOfBathrooms: event.noOfBathrooms,
      );
      viewResponse = response;
      logger("Response in AuthBloc: $response");
      logger(viewResponse!.statusMessage!);
      if (viewResponse!.status! == '200') {
        logger("TOKEN: ${viewResponse?.status ?? ''}");
        // logger("Length: ${viewResponse!.data!.length}");
        // _setAuthenticationHeaders(getCategoriesModel);
        // await _secureStorageProvider.saveUserToDisk(userData!);
        await _secureStorageProvider.add(key: 'isLoggedIn', value: 'true');
        emit(ViewQuoteLoaded());
      } else {
        FlutterToastProvider().show(message: viewResponse!.statusMessage!);
        emit(ViewQuoteFailure(message: viewResponse!.statusMessage!));
      }
    } catch (e, st) {
      logES(e, st);

      emit(ViewQuoteFailure(message: e.toString()));
    }
  }
}
