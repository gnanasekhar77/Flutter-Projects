abstract class DeleteSkuState {}

class DeleteSkuStateInitial extends DeleteSkuState {}

class DeleteSkuStateLoading extends DeleteSkuState {}

class DeleteSkuStateFailure extends DeleteSkuState {
  final String message;

  DeleteSkuStateFailure({required this.message});
}

class DeleteSkuStateLoaded extends DeleteSkuState {}
