import 'package:APaints_QGen/src/data/models/sku_request_model.dart';

abstract class ViewQuoteEvent {}

class GetViewQuoteEvent extends ViewQuoteEvent {
  final List<Quoteinfo>? quoteInfo;
  final String? discountAmount;
  final String? totalPriceWithGst;
  final String? quoteName;
  final String? projectID;
  final String? quoteType;
  final bool isExist;
  final String? projectName;
  final String? contactPerson;
  final String? mobileNumber;
  final String? siteAddress;
  final String? noOfBathrooms;

  @override
  GetViewQuoteEvent({
    required this.quoteInfo,
    required this.discountAmount,
    required this.totalPriceWithGst,
    required this.quoteName,
    required this.projectID,
    required this.quoteType,
    required this.isExist,
    required this.projectName,
    required this.contactPerson,
    required this.mobileNumber,
    required this.siteAddress,
    required this.noOfBathrooms,
  });
}
