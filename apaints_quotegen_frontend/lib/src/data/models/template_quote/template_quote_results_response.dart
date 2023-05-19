import 'package:APaints_QGen/src/data/models/sku_request_model.dart';

class TemplateQuoteResultsListResponse {
  List<Sanwaredata>? sanwaredata = [];
  List<TempQuoteSearchResultsData>? data = [];
  String? statusMessage;
  String? status;

  TemplateQuoteResultsListResponse(
      {required this.sanwaredata,
      required this.data,
      required this.statusMessage,
      required this.status});

  TemplateQuoteResultsListResponse.fromJson(Map<String, dynamic> json) {
    if (json['sanwaredata'] != null) {
      sanwaredata = <Sanwaredata>[];
      json['sanwaredata'].forEach((v) {
        sanwaredata?.add(Sanwaredata.fromJson(v));
      });
    }
    if (json['data'] != null) {
      data = <TempQuoteSearchResultsData>[];
      json['data'].forEach((v) {
        data?.add(TempQuoteSearchResultsData.fromJson(v));
      });
    }
    statusMessage = json['statusMessage'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (sanwaredata != null) {
      data['sanwaredata'] = sanwaredata?.map((v) => v.toJson()).toList();
    }
    if (this.data != null) {
      data['data'] = this.data?.map((v) => v.toJson()).toList();
    }
    data['statusMessage'] = statusMessage;
    data['status'] = status;
    return data;
  }
}

class Sanwaredata {
  String? sKURANGE;
  String? sKUCODE;
  String? sKUIMAGE;
  String? sKUCATEGORY;
  String? sKUUSP;
  String? sKUCATCODE;
  String? sKUPRODUCTCAT;
  String? sKUTYPEEXPANDED;
  String? sKUDESCRIPTION;
  String? sKUMRP;
  String? sKUSRP;
  List<AREAINFOBJ>? aREAINFOBJ;
  String? sKUDRAWING;
  String? pRODUCTCARDDESCRIPTOR;
  String? sKUBRAND;
  List<String>? aREAINFO;
  String? sKUTYPE;

  Sanwaredata(
      {required this.sKURANGE,
      required this.sKUCODE,
      required this.sKUIMAGE,
      required this.sKUCATEGORY,
      required this.sKUUSP,
      required this.sKUCATCODE,
      required this.sKUPRODUCTCAT,
      required this.sKUTYPEEXPANDED,
      required this.sKUDESCRIPTION,
      required this.sKUMRP,
      required this.sKUSRP,
      required this.aREAINFOBJ,
      required this.sKUDRAWING,
      required this.pRODUCTCARDDESCRIPTOR,
      required this.sKUBRAND,
      required this.aREAINFO,
      required this.sKUTYPE});

  Sanwaredata.fromJson(Map<String, dynamic> json) {
    sKURANGE = json['SKU_RANGE'];
    sKUCODE = json['SKUCODE'];
    sKUIMAGE = json['SKU_IMAGE'];
    sKUCATEGORY = json['SKU_CATEGORY'];
    sKUUSP = json['SKU_USP'];
    sKUCATCODE = json['SKUCATCODE'];
    sKUPRODUCTCAT = json['SKU_PRODUCT_CAT'];
    sKUTYPEEXPANDED = json['SKU_TYPE_EXPANDED'];
    sKUDESCRIPTION = json['SKU_DESCRIPTION'];
    sKUMRP = json['SKU_MRP'];
    sKUSRP = json['SKU_SRP'];
    if (json['AREAINFOBJ'] != null) {
      aREAINFOBJ = <AREAINFOBJ>[];
      json['AREAINFOBJ'].forEach((v) {
        aREAINFOBJ?.add(AREAINFOBJ.fromJson(v));
      });
    }
    sKUDRAWING = json['SKU_DRAWING'];
    pRODUCTCARDDESCRIPTOR = json['PRODUCT_CARD_DESCRIPTOR'];
    sKUBRAND = json['SKU_BRAND'];
    aREAINFO = json['AREAINFO'].cast<String>();
    sKUTYPE = json['SKU_TYPE'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['SKU_RANGE'] = sKURANGE;
    data['SKUCODE'] = sKUCODE;
    data['SKU_IMAGE'] = sKUIMAGE;
    data['SKU_CATEGORY'] = sKUCATEGORY;
    data['SKU_USP'] = sKUUSP;
    data['SKUCATCODE'] = sKUCATCODE;
    data['SKU_PRODUCT_CAT'] = sKUPRODUCTCAT;
    data['SKU_TYPE_EXPANDED'] = sKUTYPEEXPANDED;
    data['SKU_DESCRIPTION'] = sKUDESCRIPTION;
    data['SKU_MRP'] = sKUMRP;
    data['SKU_SRP'] = sKUSRP;
    if (aREAINFOBJ != null) {
      data['AREAINFOBJ'] = aREAINFOBJ?.map((v) => v.toJson()).toList();
    }
    data['SKU_DRAWING'] = sKUDRAWING;
    data['PRODUCT_CARD_DESCRIPTOR'] = pRODUCTCARDDESCRIPTOR;
    data['SKU_BRAND'] = sKUBRAND;
    data['AREAINFO'] = aREAINFO;
    data['SKU_TYPE'] = sKUTYPE;
    return data;
  }
}

// class AREAINFOBJ {
//   String? aREA;
//   String? qTY;

//   AREAINFOBJ({required this.aREA, required this.qTY});

//   AREAINFOBJ.fromJson(Map<String, dynamic> json) {
//     aREA = json['AREA'];
//     qTY = json['QTY'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['AREA'] = aREA;
//     data['QTY'] = qTY;
//     return data;
//   }
// }

class TempQuoteSearchResultsData {
  String? bUNDLENAME;
  String? sKUTYPE;
  String? sKURANGE;
  String? sKUCODE;
  String? QUANTITY;
  String? bUNDLEBRAND;
  String? bUNDLERANGE;
  String? sKUIMAGE;
  String? sKUCATEGORY;
  String? cORESKU;
  String? sKUUSP;
  String? sKUCATCODE;
  String? sKUPRODUCTCAT;
  String? sKUTYPEEXPANDED;
  String? sKUDESCRIPTION;
  String? sKUMRP;
  String? dESCRIPTION;
  String? sKUSRP;
  List<AREAINFOBJ>? aREAINFOBJ;
  String? sKUDRAWING;
  String? pRODUCTCARDDESCRIPTOR;
  String? sKUBRAND;
  List<String>? aREAINFO;
  String? sKUTYPEDUP;
  int? discount;
  String? quantity;
  int? totalPrice;
  int? totalPriceAfterDiscount = 0;

  TempQuoteSearchResultsData(
      {this.bUNDLENAME,
      this.sKUTYPE,
      this.sKURANGE,
      this.sKUCODE,
      this.QUANTITY,
      this.bUNDLEBRAND,
      this.bUNDLERANGE,
      this.sKUIMAGE,
      this.sKUCATEGORY,
      this.cORESKU,
      this.sKUUSP,
      this.sKUCATCODE,
      this.sKUPRODUCTCAT,
      this.sKUTYPEEXPANDED,
      this.sKUDESCRIPTION,
      this.sKUMRP,
      this.dESCRIPTION,
      this.sKUSRP,
      this.aREAINFOBJ,
      this.sKUDRAWING,
      this.pRODUCTCARDDESCRIPTOR,
      this.sKUBRAND,
      this.aREAINFO,
      this.sKUTYPEDUP,
      this.discount,
      this.quantity,
      this.totalPrice,
      this.totalPriceAfterDiscount});

  TempQuoteSearchResultsData.fromJson(Map<String, dynamic> json) {
    bUNDLENAME = json['BUNDLENAME'];
    sKUTYPE = json['SKUTYPE'];
    sKURANGE = json['SKU_RANGE'];
    sKUCODE = json['SKUCODE'];
    QUANTITY = json['QUANTITY'];
    bUNDLEBRAND = json['BUNDLEBRAND'];
    bUNDLERANGE = json['BUNDLERANGE'];
    sKUIMAGE = json['SKU_IMAGE'];
    sKUCATEGORY = json['SKU_CATEGORY'];
    cORESKU = json['CORESKU'];
    sKUUSP = json['SKU_USP'];
    sKUCATCODE = json['SKUCATCODE'];
    sKUPRODUCTCAT = json['SKU_PRODUCT_CAT'];
    sKUTYPEEXPANDED = json['SKU_TYPE_EXPANDED'];
    sKUDESCRIPTION = json['SKU_DESCRIPTION'];
    sKUMRP = json['SKU_MRP'];
    dESCRIPTION = json['DESCRIPTION'];
    sKUSRP = json['SKU_SRP'];
    if (json['AREAINFOBJ'] != null) {
      aREAINFOBJ = <AREAINFOBJ>[];
      json['AREAINFOBJ'].forEach((v) {
        aREAINFOBJ?.add(AREAINFOBJ.fromJson(v));
      });
    }
    sKUDRAWING = json['SKU_DRAWING'];
    pRODUCTCARDDESCRIPTOR = json['PRODUCT_CARD_DESCRIPTOR'];
    sKUBRAND = json['SKU_BRAND'];
    aREAINFO = json['AREAINFO'].cast<String>();
    sKUTYPEDUP = json['SKU_TYPE'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['BUNDLENAME'] = bUNDLENAME;
    data['SKUTYPE'] = sKUTYPE;
    data['SKU_RANGE'] = sKURANGE;
    data['SKUCODE'] = sKUCODE;
    data['QUANTITY'] = QUANTITY;
    data['BUNDLEBRAND'] = bUNDLEBRAND;
    data['BUNDLERANGE'] = bUNDLERANGE;
    data['SKU_IMAGE'] = sKUIMAGE;
    data['SKU_CATEGORY'] = sKUCATEGORY;
    data['CORESKU'] = cORESKU;
    data['SKU_USP'] = sKUUSP;
    data['SKUCATCODE'] = sKUCATCODE;
    data['SKU_PRODUCT_CAT'] = sKUPRODUCTCAT;
    data['SKU_TYPE_EXPANDED'] = sKUTYPEEXPANDED;
    data['SKU_DESCRIPTION'] = sKUDESCRIPTION;
    data['SKU_MRP'] = sKUMRP;
    data['DESCRIPTION'] = dESCRIPTION;
    data['SKU_SRP'] = sKUSRP;
    if (aREAINFOBJ != null) {
      data['AREAINFOBJ'] = aREAINFOBJ?.map((v) => v.toJson()).toList();
    }
    data['SKU_DRAWING'] = sKUDRAWING;
    data['PRODUCT_CARD_DESCRIPTOR'] = pRODUCTCARDDESCRIPTOR;
    data['SKU_BRAND'] = sKUBRAND;
    data['AREAINFO'] = aREAINFO;
    data['SKU_TYPE'] = sKUTYPEDUP;
    return data;
  }
}

class AREAINFOBJ {
  String? aREA;
  String? qTY;

  AREAINFOBJ({required this.aREA, required this.qTY});

  AREAINFOBJ.fromJson(Map<String, dynamic> json) {
    aREA = json['AREA'];
    qTY = json['QTY'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['AREA'] = aREA;
    data['QTY'] = qTY;
    return data;
  }
}
