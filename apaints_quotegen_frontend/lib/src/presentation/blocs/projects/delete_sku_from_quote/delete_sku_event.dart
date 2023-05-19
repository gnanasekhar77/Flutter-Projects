abstract class DeleteSkuEvent {}

class DelSkuEvent extends DeleteSkuEvent {
  final String? quoteID;
  final String? skuID;

  @override
  DelSkuEvent(
      {required this.quoteID, required this.skuID});
}
