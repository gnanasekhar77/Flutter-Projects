abstract class ProjectsDescriptionState {}

class ProjectDescriptionInitial extends ProjectsDescriptionState {}

class ProjectDescriptionLoading extends ProjectsDescriptionState {}

class ProjectDescriptionFailure extends ProjectsDescriptionState {
  final String message;

  ProjectDescriptionFailure({required this.message});
}

class ProjectDescriptionLoaded extends ProjectsDescriptionState {}