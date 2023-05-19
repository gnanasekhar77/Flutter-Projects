import 'package:APaints_QGen/src/presentation/views/project/projects_list.dart';

import 'package:equatable/equatable.dart';

abstract class ProjectSearchState extends Equatable {}

class ProjectSearchUninitialized extends ProjectSearchState {
  @override
  List<Object> get props => [];
}

class ProjectSearchLoading extends ProjectSearchState {
  ProjectSearchLoading();
  @override
  List<Object> get props => [];
}

class ProjectSearchLoaded extends ProjectSearchState {
  final List<ProjectsList> searchResponseModel;
  ProjectSearchLoaded({required this.searchResponseModel});
  @override
  List<Object> get props => [];
}

class ProjectSearchError extends ProjectSearchState {
  @override
  List<Object> get props => [];
}
