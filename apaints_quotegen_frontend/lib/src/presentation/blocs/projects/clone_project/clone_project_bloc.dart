import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/logger.dart';
import 'package:APaints_QGen/src/data/datasources/remote/flutter_toast_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/form_field_validator_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/data/models/view_quote_response.dart';
import 'package:APaints_QGen/src/data/repositories/clone_project_repo.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/clone_project/clone_project_event.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/clone_project/clone_project_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CloneProjectBloc extends Bloc<CloneProjectEvent, CloneProjectState> {
  final cloneProjectRepo = getSingleton<CloneProjectRepository>();
  final _validatorProvider = getSingleton<FormFieldValidatorProvider>();
  final _secureStorageProvider = getSingleton<SecureStorageProvider>();
  final _flutterToastProvider = getSingleton<FlutterToastProvider>();

  FormFieldValidatorProvider get validatorProvider => _validatorProvider;
  FlutterToastProvider get flutterToastProvider => _flutterToastProvider;

  ViewQuoteResponse? response;
  int? index;
  List<int>? itemIndex;
  bool loadingStatus = true;

  Future<void> cloneProject(
      {required String? projectID,
      required String? projectName,
      required String? contactPerson,
      required String? mobileNumber,
      required String? siteAddress,
      required String? noOfBathrooms}) async {
    add(
      CloneProjectEvent(
          projectID: projectID,
          projectName: projectName,
          contactPerson: contactPerson,
          mobileNumber: mobileNumber,
          siteAddress: siteAddress,
          noOfBathrooms: noOfBathrooms),
    );
  }

  CloneProjectBloc() : super(CloneProjectInitial()) {
    on<CloneProjectEvent>((event, emit) => _cloneProject(event, emit));
  }

  void _cloneProject(
      CloneProjectEvent event, Emitter<CloneProjectState> emit) async {
    emit(CloneProjectLoading());
    try {
      ViewQuoteResponse response = await cloneProjectRepo.cloneProjectFuture(
        projectid: event.projectID,
        projectName: event.projectName,
        contactPerson: event.contactPerson,
        mobileNumber: event.mobileNumber,
        siteAddress: event.siteAddress,
        noOfBathrooms: event.noOfBathrooms,
      );
      response = response;
      logger("Response in AuthBloc: $response");
      logger(response.statusMessage ?? '');
      if (response.status == '200') {
        logger("TOKEN: ${response.status ?? ''}");
        // logger("Category Image: ${getProjectsResponseModel!.data![0].pROJECTNAME}");
        // _setAuthenticationHeaders(getCategoriesModel);
        // await _secureStorageProvider.saveUserToDisk(userData!);
        await _secureStorageProvider.add(key: 'isLoggedIn', value: 'true');
        emit(CloneProjectLoaded());
      } else {
        FlutterToastProvider().show(message: response.statusMessage!);
        emit(CloneProjectFailure(message: response.statusMessage!));
      }
    } catch (e, st) {
      logES(e, st);

      emit(CloneProjectFailure(message: e.toString()));
    }
  }
}
