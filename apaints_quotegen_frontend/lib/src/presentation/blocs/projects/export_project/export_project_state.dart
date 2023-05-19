abstract class ExportProjectState {}

class ExportProjectInitial extends ExportProjectState {}

class ExportProjectLoading extends ExportProjectState {}

class ExportProjectFailure extends ExportProjectState {
  final String message;

  ExportProjectFailure({required this.message});
}

class ExportProjectLoaded extends ExportProjectState {}