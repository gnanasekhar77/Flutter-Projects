abstract class CompetitionSearchSanBundState {}

class CompetitionSearchSanBundInitial extends CompetitionSearchSanBundState {}

class CompetitionSearchSanBundLoading extends CompetitionSearchSanBundState {}

class CompetitionSearchSanBundFailure extends CompetitionSearchSanBundState {
  final String message;

  CompetitionSearchSanBundFailure({required this.message});
}

class CompetitionSearchSanBundLoaded extends CompetitionSearchSanBundState {}

