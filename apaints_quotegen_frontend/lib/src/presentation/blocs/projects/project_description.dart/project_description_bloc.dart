import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/logger.dart';
import 'package:APaints_QGen/src/data/datasources/remote/flutter_toast_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/form_field_validator_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/data/models/project_description_response_model.dart';
import 'package:APaints_QGen/src/data/repositories/project_description_repo.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/project_description.dart/project_description_event.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/project_description.dart/project_description_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProjectDescriptionBloc
    extends Bloc<ProjectDescriptionEvent, ProjectsDescriptionState> {
  final projectDescRepo = getSingleton<ProjectDescriptionRepository>();
  final _validatorProvider = getSingleton<FormFieldValidatorProvider>();
  final _secureStorageProvider = getSingleton<SecureStorageProvider>();
  final _flutterToastProvider = getSingleton<FlutterToastProvider>();

  FormFieldValidatorProvider get validatorProvider => _validatorProvider;
  FlutterToastProvider get flutterToastProvider => _flutterToastProvider;

  GetProjectDescriptionModel? getProjectDescriptionModel;
  int? index;
  List<int>? itemIndex;
  bool loadingStatus = true;

  void getProjectDescription({required String projectID, String? quoteID}) {
    logger('In project disc event: $projectID');
    add(
      ProjectDescEvent(
        projectID: projectID,
        quoteID: quoteID,
      ),
    );
  }

  ProjectDescriptionBloc() : super(ProjectDescriptionInitial()) {
    on<ProjectDescEvent>((event, emit) => _getProjectDescription(event, emit));
  }

  void _getProjectDescription(
      ProjectDescEvent event, Emitter<ProjectsDescriptionState> emit) async {
    emit(ProjectDescriptionLoading());
    try {
      GetProjectDescriptionModel response =
          await projectDescRepo.getProjectDescriptionFuture(event.projectID, event.quoteID);
      getProjectDescriptionModel = response;
      logger("Response in AuthBloc: $response");
      logger(getProjectDescriptionModel?.statusMessage ?? '');
      if (getProjectDescriptionModel?.status == '200') {
        logger("TOKEN: ${getProjectDescriptionModel?.status ?? ''}");
        logger("Length: ${getProjectDescriptionModel?.data?.length}");

        await _secureStorageProvider.add(key: 'isLoggedIn', value: 'true');
        emit(ProjectDescriptionLoaded());
      } else {
        FlutterToastProvider()
            .show(message: getProjectDescriptionModel?.statusMessage ?? '');
        emit(ProjectDescriptionFailure(
            message: getProjectDescriptionModel?.statusMessage ?? ''));
      }
    } catch (e, st) {
      print(e.toString());
      print(st.toString());
      logES(e, st);

      emit(ProjectDescriptionFailure(message: e.toString()));
    }
  }
  
}
