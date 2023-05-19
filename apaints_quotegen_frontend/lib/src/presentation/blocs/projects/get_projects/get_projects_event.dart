abstract class ProjectsEvent {}

class GetProjectsEvent extends ProjectsEvent {
  final String? token;
  final int? pageNum;

  @override
  GetProjectsEvent({
    this.token,
    this.pageNum
  });
}
