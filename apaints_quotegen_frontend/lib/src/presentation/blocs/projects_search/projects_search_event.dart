import 'package:equatable/equatable.dart';

abstract class ProjectSearchEvent extends Equatable {}

class ProjectSearch extends ProjectSearchEvent {
  final String query;
  final String projectID;

  ProjectSearch({required this.query, required this.projectID});

  @override
  List<Object> get props => [];
}
