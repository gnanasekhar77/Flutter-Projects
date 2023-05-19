import 'package:APaints_QGen/src/data/models/sku_request_model.dart';

abstract class DeleteQuoteEvent {}

class DelQuoteEvent extends DeleteQuoteEvent {
 
  final String? projectID;
  final String? quoteID;

  @override
  DelQuoteEvent(
      {
      required this.projectID,
      required this.quoteID,
      });
}
