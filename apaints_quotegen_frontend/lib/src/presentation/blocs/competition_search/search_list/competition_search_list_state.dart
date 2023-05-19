abstract class CompetitionSearchListState {}

class CompetitionSearchListInitial extends CompetitionSearchListState {}

class CompetitionSearchListLoading extends CompetitionSearchListState {}

class CompetitionSearchListFailure extends CompetitionSearchListState {
  final String message;

  CompetitionSearchListFailure({required this.message});
}

class CompetitionSearchListLoaded extends CompetitionSearchListState {}

