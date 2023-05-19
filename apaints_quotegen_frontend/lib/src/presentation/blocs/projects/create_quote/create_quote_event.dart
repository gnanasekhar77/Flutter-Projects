import 'package:APaints_QGen/src/data/models/sku_request_model.dart';
import 'package:flutter/material.dart';

@immutable
abstract class QuoteEvent {}

class CreateProjectEvent extends QuoteEvent {
  final String? projectName;
  final String? contactPerson;
  final String? mobileNumber;
  final String? siteAddress;
  final String? noOfBathrooms;

  CreateProjectEvent({
    required this.projectName,
    required this.contactPerson,
    required this.mobileNumber,
    required this.siteAddress,
    required this.noOfBathrooms,
  });
}

class CreateQuoteEvent extends QuoteEvent {
  final List<Quoteinfo>? quoteInfoList;
  final String? category;
  final String? brand;
  final String? range;
  final String? discountAmount;
  final String? totalPriceWithGST;
  final String? quoteName;
  final String? projectID;
  final String? quoteType;
  final bool? isExist;
  final String? quoteID;
  final String? projectName;
  final String? contactPerson;
  final String? mobileNumber;
  final String? siteAddress;
  final String? noOfBathrooms;

  CreateQuoteEvent({
    required this.quoteInfoList,
    required this.category,
    required this.brand,
    required this.range,
    required this.discountAmount,
    required this.totalPriceWithGST,
    required this.quoteName,
    required this.projectID,
    required this.quoteType,
    required this.isExist,
    required this.quoteID,
    required this.projectName,
    required this.contactPerson,
    required this.mobileNumber,
    required this.siteAddress,
    required this.noOfBathrooms,
  });
}
