abstract class CompetitionSearchListEvent {}

class GetCompetitionSearchListEvent extends CompetitionSearchListEvent {
  final String? token;

  @override
  GetCompetitionSearchListEvent(
      {required this.token});
}
