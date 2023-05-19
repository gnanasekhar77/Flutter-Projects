abstract class CloneProjectState {}

class CloneProjectInitial extends CloneProjectState {}

class CloneProjectLoading extends CloneProjectState {}

class CloneProjectFailure extends CloneProjectState {
  final String message;

  CloneProjectFailure({required this.message});
}

class CloneProjectLoaded extends CloneProjectState {}
