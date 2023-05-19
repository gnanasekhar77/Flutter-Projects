abstract class ProjectDescriptionEvent {}

class ProjectDescEvent extends ProjectDescriptionEvent {
  final String? projectID;
  final String? quoteID;

  @override
  ProjectDescEvent({this.projectID, this.quoteID});
}
