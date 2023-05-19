abstract class ProjectEvent {}

class CloneProjectEvent extends ProjectEvent {
  final String? projectID;
  final String? projectName;
  final String? contactPerson;
  final String? mobileNumber;
  final String? siteAddress;
  final String? noOfBathrooms;

  @override
  CloneProjectEvent(
      {required this.projectID,
      required this.projectName,
      required this.contactPerson,
      required this.mobileNumber,
      required this.siteAddress,
      required this.noOfBathrooms});
}
