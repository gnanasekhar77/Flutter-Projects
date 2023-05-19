abstract class CompetitionSearchResultEvent {}

class GetCompetitionSearchResultEvent extends CompetitionSearchResultEvent {
  final String? brandName;
  final String? rangeName;
  final String? skuName;

  @override
  GetCompetitionSearchResultEvent(
      {required this.brandName, required this.rangeName, this.skuName});
}
