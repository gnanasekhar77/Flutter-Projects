class FlipQuoteResponseModel {
  bool? matchedStatus;
  String? matchedText;
  List<String>? notmatchedlist;
  String? projectid;
  String? quoteid;
  String? statusMessage;
  String? status;
  Data? data;

  FlipQuoteResponseModel(
      {required this.matchedStatus,
      required this.matchedText,
      required this.notmatchedlist,
      required this.projectid,
      required this.quoteid,
      required this.statusMessage,
      required this.status,
      this.data,
      });

  FlipQuoteResponseModel.fromJson(Map<String, dynamic> json) {
    matchedStatus = json['matchedStatus'];
    matchedText = json['matchedtext'];
    notmatchedlist = json['notmatchedlist'].cast<String>();
    projectid = json['projectid'];
    quoteid = json['quoteid'];
    statusMessage = json['statusMessage'];
    status = json['status'];
     data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['matchedStatus'] = matchedStatus;
    data['matchedtext'] = matchedText;
    data['notmatchedlist'] = notmatchedlist;

    data['projectid'] = projectid;
    data['quoteid'] = quoteid;
    data['statusMessage'] = statusMessage;
    data['status'] = status;
    if (this.data != null) {
      data['data'] = this.data?.toJson();
    }
    return data;
  }

  
}

class Data {
  List<SKUListData>? data;
  String? statusMessage;
  String? status;

  Data({this.data, this.statusMessage, this.status});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <SKUListData>[];
      json['data'].forEach((v) {
        data?.add(SKUListData.fromJson(v));
      });
    }
    statusMessage = json['statusMessage'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data?.map((v) => v.toJson()).toList();
    }
    data['statusMessage'] = this.statusMessage;
    data['status'] = this.status;
    return data;
  }
}

class SKUListData {
  String? pRODUCTCARDDESCRIPTOR;
  String? sKURANGE;
  int? tOTALPRICEAFTERDISCOUNT;
  String? qUANTITY;
  String? sKUIMAGE;
  int? tOTALPRICE;
  String? sKUCATEGORY;
  String? sKUUSP;
  String? sKUPRODUCTCAT;
  String? sKUDESCRIPTION;
  int? nETDICOUNT;
  List<COMPLEMENTARY>? cOMPLEMENTARY;
  int? dISCOUNT;
  String? sKUTYPEEXPANDED;
  String? sKUMRP;
  String? sKUCODE;
  String? sKUSRP;
  List<AREAINFOBJ>? aREAINFOBJ;
  String? sKUDRAWING;
  String? sKUBRAND;
  List<String>? aREAINFO;
  int? dISCPRICE;
  String? sKUCATCODE;
  String? sKUTYPE;

  SKUListData(
      {this.pRODUCTCARDDESCRIPTOR,
      this.sKURANGE,
      this.tOTALPRICEAFTERDISCOUNT,
      this.qUANTITY,
      this.sKUIMAGE,
      this.tOTALPRICE,
      this.sKUCATEGORY,
      this.sKUUSP,
      this.sKUPRODUCTCAT,
      this.sKUDESCRIPTION,
      this.nETDICOUNT,
      this.cOMPLEMENTARY,
      this.dISCOUNT,
      this.sKUTYPEEXPANDED,
      this.sKUMRP,
      this.sKUCODE,
      this.sKUSRP,
      this.aREAINFOBJ,
      this.sKUDRAWING,
      this.sKUBRAND,
      this.aREAINFO,
      this.dISCPRICE,
      this.sKUCATCODE,
      this.sKUTYPE});

  SKUListData.fromJson(Map<String, dynamic> json) {
    pRODUCTCARDDESCRIPTOR = json['PRODUCTCARDDESCRIPTOR'];
    sKURANGE = json['SKU_RANGE'];
    tOTALPRICEAFTERDISCOUNT = json['TOTALPRICEAFTERDISCOUNT'];
    qUANTITY = json['QUANTITY'];
    sKUIMAGE = json['SKU_IMAGE'];
    tOTALPRICE = json['TOTALPRICE'];
    sKUCATEGORY = json['SKU_CATEGORY'];
    sKUUSP = json['SKU_USP'];
    sKUPRODUCTCAT = json['SKU_PRODUCT_CAT'];
    sKUDESCRIPTION = json['SKU_DESCRIPTION'];
    nETDICOUNT = json['NETDICOUNT'];
    if (json['COMPLEMENTARY'] != null) {
      cOMPLEMENTARY = <COMPLEMENTARY>[];
      json['COMPLEMENTARY'].forEach((v) {
        cOMPLEMENTARY?.add(COMPLEMENTARY.fromJson(v));
      });
    }
    dISCOUNT = json['DISCOUNT'];
    sKUTYPEEXPANDED = json['SKUTYPEEXPANDED'];
    sKUMRP = json['SKU_MRP'];
    sKUCODE = json['SKU_CODE'];
    sKUSRP = json['SKU_SRP'];
    if (json['AREAINFOBJ'] != null) {
      aREAINFOBJ = <AREAINFOBJ>[];
      json['AREAINFOBJ'].forEach((v) {
        aREAINFOBJ?.add(AREAINFOBJ.fromJson(v));
      });
    }
    sKUDRAWING = json['SKU_DRAWING'];
    sKUBRAND = json['SKU_BRAND'];
    aREAINFO = json['AREAINFO'].cast<String>();
    dISCPRICE = json['DISCPRICE'];
    sKUCATCODE = json['SKU_CATCODE'];
    sKUTYPE = json['SKU_TYPE'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['PRODUCTCARDDESCRIPTOR'] = pRODUCTCARDDESCRIPTOR;
    data['SKU_RANGE'] = sKURANGE;
    data['TOTALPRICEAFTERDISCOUNT'] = tOTALPRICEAFTERDISCOUNT;
    data['QUANTITY'] = qUANTITY;
    data['SKU_IMAGE'] = sKUIMAGE;
    data['TOTALPRICE'] = tOTALPRICE;
    data['SKU_CATEGORY'] = sKUCATEGORY;
    data['SKU_USP'] = sKUUSP;
    data['SKU_PRODUCT_CAT'] = sKUPRODUCTCAT;
    data['SKU_DESCRIPTION'] = sKUDESCRIPTION;
    data['NETDICOUNT'] = nETDICOUNT;
    if (cOMPLEMENTARY != null) {
      data['COMPLEMENTARY'] =
          cOMPLEMENTARY?.map((v) => v.toJson()).toList();
    }
    data['DISCOUNT'] = dISCOUNT;
    data['SKUTYPEEXPANDED'] = sKUTYPEEXPANDED;
    data['SKU_MRP'] = sKUMRP;
    data['SKU_CODE'] = sKUCODE;
    data['SKU_SRP'] = sKUSRP;
    if (aREAINFOBJ != null) {
      data['AREAINFOBJ'] = aREAINFOBJ?.map((v) => v.toJson()).toList();
    }
    data['SKU_DRAWING'] = sKUDRAWING;
    data['SKU_BRAND'] = sKUBRAND;
    data['AREAINFO'] = aREAINFO;
    data['DISCPRICE'] = dISCPRICE;
    data['SKU_CATCODE'] = sKUCATCODE;
    data['SKU_TYPE'] = sKUTYPE;
    return data;
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
      this.cMPCATEGORY});

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

class AREAINFOBJ {
  String? aREA;
  String? qTY;

  AREAINFOBJ({this.aREA, this.qTY});

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
