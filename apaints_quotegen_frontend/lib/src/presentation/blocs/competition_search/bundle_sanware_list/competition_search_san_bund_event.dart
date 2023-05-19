abstract class CompetitionSearchSanBundEvent {}

class GetCompetitionSearchSanBundEvent extends CompetitionSearchSanBundEvent {
  final String? range;
  final String? bundle;
  final String? sanware;

  @override
  GetCompetitionSearchSanBundEvent(
      {required this.range, required this.bundle, this.sanware});
}
