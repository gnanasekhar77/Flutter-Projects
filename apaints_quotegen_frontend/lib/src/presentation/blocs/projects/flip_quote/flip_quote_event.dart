abstract class FlipEvent {}

class FlipQuoteEvent extends FlipEvent {
  final String? projectID;
  final String? quoteID;
  final String? currentRange;
  final String? selectedRange;
  final String? createdType;
  final bool? areyousure;
  final String? quoteName;

  @override
  FlipQuoteEvent(
      {required this.projectID,
      required this.quoteID,
      required this.currentRange,
      required this.selectedRange,
      required this.createdType,
      required this.areyousure,
      required this.quoteName
      });
}
