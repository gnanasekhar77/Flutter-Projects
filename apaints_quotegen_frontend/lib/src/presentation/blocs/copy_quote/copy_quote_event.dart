abstract class CopyQuoteEvent {}

class GetCopyQuoteEvent extends CopyQuoteEvent {
  final String? projectID;
  final String? quoteID;
  final String? quoteName;

  @override
  GetCopyQuoteEvent(
      {required this.projectID,
      required this.quoteID,
      required this.quoteName});
}


