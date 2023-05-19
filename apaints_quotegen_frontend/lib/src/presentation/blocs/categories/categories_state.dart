abstract class CategoriesState {}

class CategoriesInitial extends CategoriesState {}

class CategoriesLoading extends CategoriesState {}

class CategoriesFailure extends CategoriesState {
  final String message;

  CategoriesFailure({required this.message});
}

class CategoriesLoaded extends CategoriesState {}
