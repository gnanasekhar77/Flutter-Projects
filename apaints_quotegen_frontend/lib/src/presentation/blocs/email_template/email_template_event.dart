abstract class EmailTemplateEvent {}

class GetEmailTemplateEvent extends EmailTemplateEvent {
  final String? projectID;
  final String? quoteID;
  final String? emailID;
  final String? category;
  final String? total;
  final String? userName;

  @override
  GetEmailTemplateEvent(
      {
      required this.projectID,
      required this.quoteID,
      required this.emailID,
      required this.category,
      required this.total,
      required this.userName});
}
