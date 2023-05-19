import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/logger.dart';
import 'package:APaints_QGen/src/data/datasources/remote/flutter_toast_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/form_field_validator_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/data/models/export_project_response_model.dart';
import 'package:APaints_QGen/src/data/repositories/export_project_repo.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/export_project/export_project_event.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/export_project/export_project_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExportProjectBloc
    extends Bloc<ExportProjectEvent, ExportProjectState> {
  final exportProjectRepo = getSingleton<ExportProjectRepository>();
  final _validatorProvider = getSingleton<FormFieldValidatorProvider>();
  final _secureStorageProvider = getSingleton<SecureStorageProvider>();
  final _flutterToastProvider = getSingleton<FlutterToastProvider>();

  FormFieldValidatorProvider get validatorProvider => _validatorProvider;
  FlutterToastProvider get flutterToastProvider => _flutterToastProvider;

  ExportProjectResponseModel? exportProjectResponseModel;
  int? index;
  List<int>? itemIndex;
  bool loadingStatus = true;

  void getExportProject({required String projectID, String? quoteID}) {
    add(
      ExportEvent(
        projectID: projectID,
        quoteID: quoteID,
      ),
    );
  }

  ExportProjectBloc() : super(ExportProjectInitial()) {
    on<ExportEvent>((event, emit) => _getExportProject(event, emit));
  }

  void _getExportProject(
      ExportEvent event, Emitter<ExportProjectState> emit) async {
    emit(ExportProjectLoading());
    try {
      ExportProjectResponseModel response =
          await exportProjectRepo.getExportProjectFuture(event.projectID, event.quoteID);
      exportProjectResponseModel = response;
      logger("Response in AuthBloc: $response");
      logger(exportProjectResponseModel?.status ?? '');
      if (exportProjectResponseModel?.status == '200') {
        logger("TOKEN: ${exportProjectResponseModel?.status ?? ''}");
        // logger("Length: ${exportProjectResponseModel?.data?.length}");

        await _secureStorageProvider.add(key: 'isLoggedIn', value: 'true');
        emit(ExportProjectLoaded());
      } else {
        FlutterToastProvider()
            .show(message: exportProjectResponseModel?.status ?? '');
        emit(ExportProjectFailure(
            message: exportProjectResponseModel?.status ?? ''));
      }
    } catch (e, st) {
      print(e.toString());
      print(st.toString());
      logES(e, st);

      emit(ExportProjectFailure(message: e.toString()));
    }
  }
}
