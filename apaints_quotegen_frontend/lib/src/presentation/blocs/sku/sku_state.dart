abstract class SkuState {}

class SkuInitial extends SkuState {}

class SkuLoading extends SkuState {}

class SkuFailure extends SkuState {
  final String message;

  SkuFailure({required this.message});
}

class SkuLoaded extends SkuState {}

class SkuReLoaded extends SkuState {}
