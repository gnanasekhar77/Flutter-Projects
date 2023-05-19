abstract class TempQuoteSearchResultEvent {}

class GetTempQuoteSearchResultEvent extends TempQuoteSearchResultEvent {
  final String? brandName;
  final String? rangeName;
  final String? bundleType;
  final String? sanwareType;

  @override
  GetTempQuoteSearchResultEvent({
    required this.brandName,
    required this.rangeName,
    required this.bundleType,
    required this.sanwareType,
  });
}
