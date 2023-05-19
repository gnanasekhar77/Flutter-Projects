class CompetitionSearchSanBundResponse {
  Bundleinfo? bundleinfo;
  String? statusMessage;
  String? status;

  CompetitionSearchSanBundResponse(
      {this.bundleinfo, this.statusMessage, this.status});

  CompetitionSearchSanBundResponse.fromJson(Map<String, dynamic> json) {
    bundleinfo = json['bundleinfo'] != null
        ? Bundleinfo.fromJson(json['bundleinfo'])
        : null;
    statusMessage = json['statusMessage'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['bundleinfo'] = bundleinfo?.toJson();
    data['statusMessage'] = statusMessage;
    data['status'] = status;
    return data;
  }
}

class Bundleinfo {
  List<Sanware>? sanware;
  List<Bundle>? bundle;
  String? statusMessage;
  String? status;

  Bundleinfo({this.sanware, this.bundle, this.statusMessage, this.status});

  Bundleinfo.fromJson(Map<String, dynamic> json) {
    if (json['sanware'] != null) {
      sanware = <Sanware>[];
      json['sanware'].forEach((v) {
        sanware?.add(Sanware.fromJson(v));
      });
    }
    if (json['bundle'] != null) {
      bundle = <Bundle>[];
      json['bundle'].forEach((v) {
        bundle?.add(Bundle.fromJson(v));
      });
    }
    statusMessage = json['statusMessage'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['sanware'] = sanware?.map((v) => v.toJson()).toList();
    data['bundle'] = bundle?.map((v) => v.toJson()).toList();
    data['statusMessage'] = statusMessage;
    data['status'] = status;
    return data;
  }
}

class Sanware {
  String? sANWARETYPE;
  List<AREANAME>? aREANAME;

  Sanware({this.sANWARETYPE, this.aREANAME});

  Sanware.fromJson(Map<String, dynamic> json) {
    sANWARETYPE = json['SANWARETYPE'];
    if (json['AREANAME'] != null) {
      aREANAME = <AREANAME>[];
      json['AREANAME'].forEach((v) {
        aREANAME?.add(AREANAME.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['SANWARETYPE'] = sANWARETYPE;
    data['AREANAME'] = aREANAME?.map((v) => v.toJson()).toList();
    return data;
  }
}

class AREANAME {
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
  int? dISCOUNT;
  String? sKUTYPEEXPANDED;
  String? sKUMRP;
  String? sKUCODE;
  String? sKUSRP;
  List<AREAINFOBJ>? aREAINFOBJ;
  String? sKUDRAWING;
  String? sKUBRAND;
  List<String>? aREAINFO;
  String? sKUCATCODE;
  String? sKUTYPE;

  AREANAME(
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
      this.dISCOUNT,
      this.sKUTYPEEXPANDED,
      this.sKUMRP,
      this.sKUCODE,
      this.sKUSRP,
      this.aREAINFOBJ,
      this.sKUDRAWING,
      this.sKUBRAND,
      this.aREAINFO,
      this.sKUCATCODE,
      this.sKUTYPE});

  AREANAME.fromJson(Map<String, dynamic> json) {
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
    data['DISCOUNT'] = dISCOUNT;
    data['SKUTYPEEXPANDED'] = sKUTYPEEXPANDED;
    data['SKU_MRP'] = sKUMRP;
    data['SKU_CODE'] = sKUCODE;
    data['SKU_SRP'] = sKUSRP;
    data['AREAINFOBJ'] = aREAINFOBJ?.map((v) => v.toJson()).toList();
    data['SKU_DRAWING'] = sKUDRAWING;
    data['SKU_BRAND'] = sKUBRAND;
    data['AREAINFO'] = aREAINFO;
    data['SKU_CATCODE'] = sKUCATCODE;
    data['SKU_TYPE'] = sKUTYPE;
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

class Bundle {
  String? bUNDLENAME;
  List<AREANAME>? aREANAME;

  Bundle({this.bUNDLENAME, this.aREANAME});

  Bundle.fromJson(Map<String, dynamic> json) {
    bUNDLENAME = json['BUNDLENAME'];
    if (json['AREANAME'] != null) {
      aREANAME = <AREANAME>[];
      json['AREANAME'].forEach((v) {
        aREANAME?.add(AREANAME.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['BUNDLENAME'] = bUNDLENAME;
    data['AREANAME'] = aREANAME?.map((v) => v.toJson()).toList();
    return data;
  }
}