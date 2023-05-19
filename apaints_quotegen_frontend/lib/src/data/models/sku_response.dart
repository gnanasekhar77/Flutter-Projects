import 'dart:convert';

import 'package:APaints_QGen/src/core/utils/logger.dart';
import 'package:APaints_QGen/src/data/models/sku_request_model.dart';
import 'package:flutter/material.dart';

class SKUResponse {
  List<SKUData>? data;
  String? statusMessage;
  String? status;

  SKUResponse({this.data, this.statusMessage, this.status});

  SKUResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <SKUData>[];
      json['data'].forEach((v) {
        data!.add(SKUData.fromJson(v));
      });
    }
    statusMessage = json['statusMessage'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['statusMessage'] = statusMessage;
    data['status'] = status;
    return data;
  }
}

class SKUData {
  String? sKURANGE;
  String? sKUIMAGE;
  String? sKUCATEGORY;
  String? sKUUSP;
  String? sKUPRODUCTCAT;
  String? sKUDESCRIPTION;
  List<COMPLEMENTARY>? complementary;
  String? sKUMRP;
  String? sKUCODE;
  String? sKUSRP;
  String? sKUDRAWING;
  String? sKUBRAND;
  List<String>? aREAINFO;
  String? skuCatCode;
  String? sKUTYPE;
  int? discount;
  String? quantity;
  int? totalPrice;
  int? totalPriceAfterDiscount = 0;
  int? index;
  List<Area>? areaInfo;
  String? skuTypeExpanded;
  String? productCardDescriptior;
  String? netDiscount;
  num? discPrice;

  SKUData(
      {this.sKURANGE,
      this.sKUIMAGE,
      this.sKUCATEGORY,
      this.sKUUSP,
      this.sKUPRODUCTCAT,
      this.sKUDESCRIPTION,
      this.complementary,
      this.sKUMRP,
      this.sKUCODE,
      this.sKUSRP,
      this.sKUDRAWING,
      this.sKUBRAND,
      this.aREAINFO,
      this.skuCatCode,
      this.sKUTYPE,
      this.discount,
      this.quantity,
      this.totalPrice,
      this.totalPriceAfterDiscount,
      this.index,
      this.areaInfo,
      this.skuTypeExpanded,
      this.productCardDescriptior,
      this.netDiscount,
      this.discPrice});

  SKUData.fromJson(Map<String, dynamic> json) {
    sKURANGE = json['SKU_RANGE'];
    sKUIMAGE = json['SKU_IMAGE'];
    sKUCATEGORY = json['SKU_CATEGORY'];
    sKUUSP = json['SKU_USP'];
    sKUPRODUCTCAT = json['SKU_PRODUCT_CAT'];
    sKUDESCRIPTION = json['SKU_DESCRIPTION'];
    if (json['COMPLEMENTARY'] != null) {
      complementary = <COMPLEMENTARY>[];
      json['COMPLEMENTARY'].forEach((v) {
        complementary?.add(COMPLEMENTARY.fromJson(v));
      });
    }
    sKUMRP = json['SKU_MRP'];
    sKUCODE = json['SKU_CODE'];
    sKUSRP = json['SKU_SRP'];
    sKUDRAWING = json['SKU_DRAWING'];
    sKUBRAND = json['SKU_BRAND'];
    aREAINFO = (json['AREAINFO'] ?? []).cast<String>();
    skuCatCode = json['SKU_CATCODE'];
    sKUTYPE = json['SKU_TYPE'];
    discount = json['DISCOUNT'];
    quantity = json['QUANTITY'];
    totalPrice = json['TOTALPRICE'];
    totalPriceAfterDiscount = json['TOTALPRICEAFTERDISCOUNT'];
    if (json['AREAINFOBJ'] != null) {
      areaInfo = <Area>[];
      json['AREAINFOBJ'].forEach((v) {
        areaInfo?.add(Area.fromJson(v));
      });
    }
    skuTypeExpanded = json['SKUTYPEEXPANDED'];
    productCardDescriptior = json['PRODUCTCARDDESCRIPTOR'];
    netDiscount = json['NETDISCOUNT'];
    discPrice = json['DISCPRICE'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['SKU_RANGE'] = sKURANGE;
    data['SKU_IMAGE'] = sKUIMAGE;
    data['SKU_CATEGORY'] = sKUCATEGORY;
    data['SKU_USP'] = sKUUSP;
    data['SKU_PRODUCT_CAT'] = sKUPRODUCTCAT;
    data['SKU_DESCRIPTION'] = sKUDESCRIPTION;
    if (complementary != null) {
      data['COMPLEMENTARY'] = complementary?.map((v) => v.toJson()).toList();
    }
    data['SKU_MRP'] = sKUMRP;
    data['SKU_CODE'] = sKUCODE;
    data['SKU_SRP'] = sKUSRP;
    data['SKU_DRAWING'] = sKUDRAWING;
    data['SKU_BRAND'] = sKUBRAND;
    data['AREAINFO'] = aREAINFO;

    data['SKU_CATCODE'] = skuCatCode;
    data['SKU_TYPE'] = sKUTYPE;
    data['DISCOUNT'] = discount;
    data['QUANTITY'] = quantity;
    data['TOTALPRICE'] = totalPrice;
    data['TOTALPRICEAFTERDISCOUNT'] = totalPriceAfterDiscount;
    if (areaInfo != null) {
      data['AREAINFOBJ'] = areaInfo?.map((v) => v.toJson()).toList();
    }
    data['SKUTYPEEXPANDED'] = skuTypeExpanded;
    data['PRODUCTCARDDESCRIPTOR'] = productCardDescriptior;
    data['NETDISCOUNT'] = netDiscount;
    data['DISCPRICE'] = discPrice;
    return data;
  }

  static Map<String, dynamic> toMap(SKUData skuData) => {
        'SKU_RANGE': skuData.sKURANGE,
        'SKU_IMAGE': skuData.sKUIMAGE,
        'SKU_CATEGORY': skuData.sKUCATEGORY,
        'SKU_USP': skuData.sKUUSP,
        'SKU_PRODUCT_CAT': skuData.sKUPRODUCTCAT,
        'SKU_DESCRIPTION': skuData.sKUDESCRIPTION,
        'COMPLEMENTARY': skuData.complementary?.map((v) => v.toJson()).toList(),
        'SKU_MRP': skuData.sKUMRP,
        'SKU_CODE': skuData.sKUCODE,
        'SKU_SRP': skuData.sKUSRP,
        'SKU_DRAWING': skuData.sKUDRAWING,
        'SKU_BRAND': skuData.sKUBRAND,
        'AREAINFO': skuData.aREAINFO,
        'SKU_CATCODE': skuData.skuCatCode,
        'SKU_TYPE': skuData.sKUTYPE,
        'DISCOUNT': skuData.discount,
        'QUANTITY': skuData.quantity,
        'TOTALPRICE': skuData.totalPrice,
        'TOTALPRICEAFTERDISCOUNT': skuData.totalPriceAfterDiscount,
        'AREAINFOBJ': skuData.areaInfo?.map((v) => v.toJson()).toList(),
        'SKUTYPEEXPANDED': skuData.skuTypeExpanded,
        'PRODUCTCARDDESCRIPTOR': skuData.productCardDescriptior,
        'NETDISCOUNT': skuData.netDiscount,
        'DISCPRICE': skuData.discPrice
      };

  static Map<String, dynamic> fromMap(SKUData skuData) => {
        'SKU_RANGE': skuData.sKURANGE,
        'SKU_IMAGE': skuData.sKUIMAGE,
        'SKU_CATEGORY': skuData.sKUCATEGORY,
        'SKU_USP': skuData.sKUUSP,
        'SKU_PRODUCT_CAT': skuData.sKUPRODUCTCAT,
        'SKU_DESCRIPTION': skuData.sKUDESCRIPTION,
        'COMPLEMENTARY': skuData.complementary?.map((v) => v.toJson()).toList(),
        'SKU_MRP': skuData.sKUMRP,
        'SKU_CODE': skuData.sKUCODE,
        'SKU_SRP': skuData.sKUSRP,
        'SKU_DRAWING': skuData.sKUDRAWING,
        'SKU_BRAND': skuData.sKUBRAND,
        'AREAINFO': skuData.aREAINFO,
        'SKU_CATCODE': skuData.skuCatCode,
        'SKU_TYPE': skuData.sKUTYPE,
        'DISCOUNT': skuData.discount,
        'QUANTITY': skuData.quantity,
        'TOTALPRICE': skuData.totalPrice,
        'TOTALPRICEAFTERDISCOUNT': skuData.totalPriceAfterDiscount,
        'AREAINFOBJ': skuData.areaInfo?.map((v) => v.toJson()).toList(),
        'SKUTYPEEXPANDED': skuData.skuTypeExpanded,
        'PRODUCTCARDDESCRIPTOR': skuData.productCardDescriptior,
        'NETDISCOUNT': skuData.netDiscount,
        'DISCPRICE': skuData.discPrice
      };

  static String encode(List<SKUData> skus) => json.encode(
        skus.map<Map<String, dynamic>>((sku) => SKUData.toMap(sku)).toList(),
      );

  static List<SKUData> decode(String skus) {
    return (json.decode(skus) as List<dynamic>).map((item) {
      return SKUData.fromJson(item);
    }).toList();
  }
}

class COMPLEMENTARY {
  String? cMPSRP;
  String? cMPUSP;
  String? cMPMR;
  String? cMPDESCRIPTION;
  String? cMPDRAWING;
  String? cMPRANGE;
  String? cMPPRODUCTCAT;
  String? cMPSKUCODE;
  String? cMPBRAND;
  String? cMPSKUTYPE;
  String? cMPIMAGE;
  String? cMPCATCODE;
  String? cMPCATEGORY;
  TextEditingController? compController = TextEditingController(text: '');

  COMPLEMENTARY(
      {this.cMPSRP,
      this.cMPUSP,
      this.cMPMR,
      this.cMPDESCRIPTION,
      this.cMPDRAWING,
      this.cMPRANGE,
      this.cMPPRODUCTCAT,
      this.cMPSKUCODE,
      this.cMPBRAND,
      this.cMPSKUTYPE,
      this.cMPIMAGE,
      this.cMPCATCODE,
      this.cMPCATEGORY,
      this.compController});

  COMPLEMENTARY.fromJson(Map<String, dynamic> json) {
    cMPSRP = json['CMP_SRP'];
    cMPUSP = json['CMP_USP'];
    cMPMR = json['CMP_MR'];
    cMPDESCRIPTION = json['CMP_DESCRIPTION'];
    cMPDRAWING = json['CMP_DRAWING'];
    cMPRANGE = json['CMP_RANGE'];
    cMPPRODUCTCAT = json['CMP_PRODUCT_CAT'];
    cMPSKUCODE = json['CMP_SKU_CODE'];
    cMPBRAND = json['CMP_BRAND'];
    cMPSKUTYPE = json['CMP_SKU_TYPE'];
    cMPIMAGE = json['CMP_IMAGE'];
    cMPCATCODE = json['CMP_CAT_CODE'];
    cMPCATEGORY = json['CMP_CATEGORY'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['CMP_SRP'] = cMPSRP;
    data['CMP_USP'] = cMPUSP;
    data['CMP_MR'] = cMPMR;
    data['CMP_DESCRIPTION'] = cMPDESCRIPTION;
    data['CMP_DRAWING'] = cMPDRAWING;
    data['CMP_RANGE'] = cMPRANGE;
    data['CMP_PRODUCT_CAT'] = cMPPRODUCTCAT;
    data['CMP_SKU_CODE'] = cMPSKUCODE;
    data['CMP_BRAND'] = cMPBRAND;
    data['CMP_SKU_TYPE'] = cMPSKUTYPE;
    data['CMP_IMAGE'] = cMPIMAGE;
    data['CMP_CAT_CODE'] = cMPCATCODE;
    data['CMP_CATEGORY'] = cMPCATEGORY;
    return data;
  }
}
