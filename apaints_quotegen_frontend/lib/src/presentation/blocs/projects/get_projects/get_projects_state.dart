abstract class ProjectsState {}

class GetProjectsInitial extends ProjectsState {}

class GetProjectsLoading extends ProjectsState {}

class GetProjectsFailure extends ProjectsState {
  final String message;

  GetProjectsFailure({required this.message});
}

class GetProjectsLoaded extends ProjectsState {}
