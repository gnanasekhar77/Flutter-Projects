abstract class SkuEvent {}

class GetSkuEvent extends SkuEvent {
  final String? category;
  final String? brand;
  final String? range;
  final String? area;
  final int limit;

  @override
  GetSkuEvent(
      {required this.category,
      required this.brand,
      required this.range,
      required this.area,
      required this.limit});
}

class GetRefreshSkuEvent extends SkuEvent {
  final String? category;
  final String? brand;
  final String? range;
  final String? area;
  final int limit;

  @override
  GetRefreshSkuEvent(
      {required this.category,
      required this.brand,
      required this.range,
      required this.area,
      required this.limit});
}

class GetSkuCartDataEvent extends SkuEvent {
  @override
  GetSkuCartDataEvent();
}
