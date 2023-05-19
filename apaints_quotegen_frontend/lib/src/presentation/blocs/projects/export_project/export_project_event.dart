abstract class ExportProjectEvent {}

class ExportEvent extends ExportProjectEvent {
  final String? projectID;
  final String? quoteID;

  @override
  ExportEvent({this.projectID, this.quoteID});
}
