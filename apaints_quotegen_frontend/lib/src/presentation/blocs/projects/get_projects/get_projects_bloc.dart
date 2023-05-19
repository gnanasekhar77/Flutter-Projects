import 'package:APaints_QGen/src/core/utils/get_it.dart';
import 'package:APaints_QGen/src/core/utils/logger.dart';
import 'package:APaints_QGen/src/data/datasources/remote/flutter_toast_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/form_field_validator_provider.dart';
import 'package:APaints_QGen/src/data/datasources/remote/secure_storage_provider.dart';
import 'package:APaints_QGen/src/data/models/get_projects_response_model.dart';
import 'package:APaints_QGen/src/data/repositories/projects_repo.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/get_projects/get_projects_event.dart';
import 'package:APaints_QGen/src/presentation/blocs/projects/get_projects/get_projects_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProjectsListBloc extends Bloc<GetProjectsEvent, ProjectsState> {
  final projectsRepo = getSingleton<GetProjectsRepository>();
  final _validatorProvider = getSingleton<FormFieldValidatorProvider>();
  final _secureStorageProvider = getSingleton<SecureStorageProvider>();
  final _flutterToastProvider = getSingleton<FlutterToastProvider>();

  FormFieldValidatorProvider get validatorProvider => _validatorProvider;
  FlutterToastProvider get flutterToastProvider => _flutterToastProvider;

  GetProjectsResponseModel? getProjectsResponseModel;
  int? index;
  List<int>? itemIndex;
  bool loadingStatus = true;

  Future<void> getProjects(int pageNum) async {
    add(
      GetProjectsEvent(pageNum: pageNum),
    );
  }

  ProjectsListBloc() : super(GetProjectsInitial()) {
    on<GetProjectsEvent>((event, emit) => _getProjects(event, emit));
  }

  void _getProjects(GetProjectsEvent event, Emitter<ProjectsState> emit) async {
    emit(GetProjectsLoading());
    try {
      GetProjectsResponseModel response =
          await projectsRepo.getProjectsFuture(event.pageNum??1);
      getProjectsResponseModel = response;
      logger("Response in AuthBloc: $response");
      if (getProjectsResponseModel!.status == '200') {
        logger("TOKEN: ${getProjectsResponseModel?.status ?? ''}");
        logger("Length: ${(getProjectsResponseModel?.data??[]).length}");
        // logger("Category Image: ${getProjectsResponseModel!.data![0].pROJECTNAME}");
        // _setAuthenticationHeaders(getCategoriesModel);
        // await _secureStorageProvider.saveUserToDisk(userData!);
        await _secureStorageProvider.add(key: 'isLoggedIn', value: 'true');
        emit(GetProjectsLoaded());
      } else {
        FlutterToastProvider()
            .show(message: (getProjectsResponseModel?.statusMessage??''));
        emit(GetProjectsFailure(
            message: (getProjectsResponseModel?.statusMessage??'')));
      }
    } catch (e, st) {
      logES(e, st);

      emit(GetProjectsFailure(message: e.toString()));
    }
  }
}
