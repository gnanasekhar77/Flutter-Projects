abstract class CategoriesEvent {}

class GetCategoriesEvent extends CategoriesEvent {
  final String? token;

  @override
  GetCategoriesEvent({
    this.token,
  });
}

class GetCartDataEvent extends GetCategoriesEvent {
  @override
  GetCartDataEvent();
}
