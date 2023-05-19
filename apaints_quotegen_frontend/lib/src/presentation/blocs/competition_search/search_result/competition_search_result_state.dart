abstract class CompetitionSearchResultState {}

class CompetitionSearchResultInitial extends CompetitionSearchResultState {}

class CompetitionSearchResultLoading extends CompetitionSearchResultState {}

class CompetitionSearchResultFailure extends CompetitionSearchResultState {
  final String message;

  CompetitionSearchResultFailure({required this.message});
}

class CompetitionSearchResultLoaded extends CompetitionSearchResultState {}

