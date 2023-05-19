import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/logger.dart';
import 'package:APaints_QGen/src/data/datasources/remote/flutter_toast_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/form_field_validator_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/data/models/create_project_response_model.dart';
import 'package:APaints_QGen/src/data/models/create_quote_to_existing_project_response_model.dart';
import 'package:APaints_QGen/src/data/models/sku_request_model.dart';
import 'package:APaints_QGen/src/data/repositories/create_project_repo.dart';
import 'package:APaints_QGen/src/data/repositories/create_quote_to_project_repo.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/create_quote/create_quote_event.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/create_quote/create_quote_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateQuoteBloc extends Bloc<QuoteEvent, CreateQuoteState> {
  final createQuoteRepo = getSingleton<CreateQuoteToProjectRepository>();
  final createProjectRepo = getSingleton<CreateProjectRepository>();
  final _validatorProvider = getSingleton<FormFieldValidatorProvider>();
  final _secureStorageProvider = getSingleton<SecureStorageProvider>();
  final _flutterToastProvider = getSingleton<FlutterToastProvider>();

  FormFieldValidatorProvider get validatorProvider => _validatorProvider;
  FlutterToastProvider get flutterToastProvider => _flutterToastProvider;

  CreateQuoteToExistingProjectResponseModel?
      createQuoteToExistingProjectResponseModel;
  CreateProjectResponse? createProjectResponse;
  int? index;
  List<int>? itemIndex;
  bool loadingStatus = true;

  void createQuote(
      {required List<Quoteinfo>? quoteInfoList,
      required String? category,
      required String? brand,
      required String? range,
      required String? discountAmount,
      required String? totalPriceWithGST,
      required String? quoteName,
      required String? projectID,
      required String? quoteType,
      required bool isExist,
      required String? quoteID,
      required String? projectName,
      required String? contactPerson,
      required String? mobileNumber,
      required String? siteAddress,
      required String? noOfBathrooms}) {
    add(
      CreateQuoteEvent(
          quoteInfoList: quoteInfoList,
          category: category,
          brand: brand,
          range: range,
          discountAmount: discountAmount,
          totalPriceWithGST: totalPriceWithGST,
          quoteName: quoteName,
          projectID: projectID,
          quoteType: quoteType,
          isExist: isExist,
          quoteID: quoteID,
          projectName: projectName,
          contactPerson: contactPerson,
          mobileNumber: mobileNumber,
          siteAddress: siteAddress,
          noOfBathrooms: noOfBathrooms),
    );
  }

  void createProject(
      {required String? projectName,
      required String? contactPerson,
      required String? mobileNumber,
      required String? siteAddress,
      required String? noOfBathrooms}) {
    add(
      CreateProjectEvent(
          projectName: projectName,
          contactPerson: contactPerson,
          mobileNumber: mobileNumber,
          siteAddress: siteAddress,
          noOfBathrooms: noOfBathrooms),
    );
  }

  CreateQuoteBloc() : super(CreateQuoteInitial()) {
    on<CreateQuoteEvent>((event, emit) => _createQuote(event, emit));
    on<CreateProjectEvent>((event, emit) => _createProject(event, emit));
  }

  void _createQuote(
      CreateQuoteEvent event, Emitter<CreateQuoteState> emit) async {
    emit(CreateQuoteLoading());
    try {
      CreateQuoteToExistingProjectResponseModel response =
          await createQuoteRepo.createQuoteFuture(
        quoteInfo: event.quoteInfoList,
        category: event.category,
        brand: event.brand,
        range: event.range,
        discountAmount: event.discountAmount,
        totalPriceWithGST: event.totalPriceWithGST,
        quoteName: event.quoteName,
        projectid: event.projectID,
        quoteType: event.quoteType,
        isExist: event.isExist,
        quoteID: event.quoteID,
        projectName: event.projectName,
        contactPerson: event.contactPerson,
        mobileNumber: event.mobileNumber,
        siteAddress: event.siteAddress,
        noOfBathrooms: event.noOfBathrooms,
      );
      createQuoteToExistingProjectResponseModel = response;
      logger("Response in AuthBloc: $response");
      logger(createQuoteToExistingProjectResponseModel!.status!);
      if (createQuoteToExistingProjectResponseModel!.status! == '200' ||
          createQuoteToExistingProjectResponseModel!.statusMessage ==
              'Quote Information is Empty') {
        logger(
            "TOKEN: ${createQuoteToExistingProjectResponseModel?.status ?? ''}");
        // logger("Category Image: ${getProjectsResponseModel!.data![0].pROJECTNAME}");
        // _setAuthenticationHeaders(getCategoriesModel);
        // await _secureStorageProvider.saveUserToDisk(userData!);
        await _secureStorageProvider.add(key: 'isLoggedIn', value: 'true');
        emit(CreateQuoteLoaded());
      } else {
        // FlutterToastProvider().show(
        //     message: createQuoteToExistingProjectResponseModel!.statusMessage!);
        emit(CreateQuoteFailure(
            message:
                createQuoteToExistingProjectResponseModel!.statusMessage!));
      }
    } catch (e, st) {
      logES(e, st);

      emit(CreateQuoteFailure(message: e.toString()));
    }
  }

  void _createProject(
      CreateProjectEvent event, Emitter<CreateQuoteState> emit) async {
    emit(CreateQuoteLoading());
    try {
      CreateProjectResponse response =
          await createProjectRepo.createProjectFuture(
        projectName: event.projectName,
        contactPerson: event.contactPerson,
        mobileNumber: event.mobileNumber,
        siteAddress: event.siteAddress,
        noOfBathrooms: event.noOfBathrooms,
      );
      createProjectResponse = response;
      logger("Response in AuthBloc: $response");
      logger(createProjectResponse?.statusMessage ?? '');
      if (createProjectResponse?.status == '200') {
        logger("TOKEN: ${createProjectResponse?.status ?? ''}");
        // logger("Category Image: ${getProjectsResponseModel!.data![0].pROJECTNAME}");
        // _setAuthenticationHeaders(getCategoriesModel);
        // await _secureStorageProvider.saveUserToDisk(userData!);
        await _secureStorageProvider.add(key: 'isLoggedIn', value: 'true');
        emit(CreateProjectLoaded());
      } else {
        // FlutterToastProvider().show(
        //     message: createQuoteToExistingProjectResponseModel!.statusMessage!);
        emit(CreateProjectFailure(
            message: createProjectResponse!.statusMessage!));
      }
    } catch (e, st) {
      logES(e, st);

      emit(CreateProjectFailure(message: e.toString()));
    }
  }
}
