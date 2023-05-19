class SearchResponseModel {
  List<SearchData>? data;
  int? rangecount;
  List<String>? mappedranges;
  String? statusMessage;
  String? status;

  SearchResponseModel(
      {this.data,
      this.rangecount,
      this.mappedranges,
      this.statusMessage,
      this.status});

  SearchResponseModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <SearchData>[];
      json['data'].forEach((v) {
        data!.add(SearchData.fromJson(v));
      });
    }
    rangecount = json['rangecount'];
    mappedranges = json['mappedranges'].cast<String>();
    statusMessage = json['statusMessage'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['rangecount'] = rangecount;
    data['mappedranges'] = mappedranges;
    data['statusMessage'] = statusMessage;
    data['status'] = status;
    return data;
  }
}

class SearchData {
  String? sKURANGE;
  String? sKUIMAGE;
  String? sKUCATEGORY;
  String? sKUUSP;
  String? sKUPRODUCTCAT;
  String? sKUDESCRIPTION;
  List<COMPLEMENTARY>? cOMPLEMENTARY;
  String? sKUMRP;
  String? sKUCODE;
  String? sKUSRP;
  String? sKUDRAWING;
  String? sKUBRAND;
  List<String>? aREAINFO;
  String? sKUCATCODE;
  String? sKUTYPE;

  SearchData(
      {this.sKURANGE,
      this.sKUIMAGE,
      this.sKUCATEGORY,
      this.sKUUSP,
      this.sKUPRODUCTCAT,
      this.sKUDESCRIPTION,
      this.cOMPLEMENTARY,
      this.sKUMRP,
      this.sKUCODE,
      this.sKUSRP,
      this.sKUDRAWING,
      this.sKUBRAND,
      this.aREAINFO,
      this.sKUCATCODE,
      this.sKUTYPE});

  SearchData.fromJson(Map<String, dynamic> json) {
    sKURANGE = json['SKU_RANGE'];
    sKUIMAGE = json['SKU_IMAGE'];
    sKUCATEGORY = json['SKU_CATEGORY'];
    sKUUSP = json['SKU_USP'];
    sKUPRODUCTCAT = json['SKU_PRODUCT_CAT'];
    sKUDESCRIPTION = json['SKU_DESCRIPTION'];
    if (json['COMPLEMENTARY'] != null) {
      cOMPLEMENTARY = <COMPLEMENTARY>[];
      json['COMPLEMENTARY'].forEach((v) {
        cOMPLEMENTARY!.add(COMPLEMENTARY.fromJson(v));
      });
    }
    sKUMRP = json['SKU_MRP'];
    sKUCODE = json['SKU_CODE'];
    sKUSRP = json['SKU_SRP'];
    sKUDRAWING = json['SKU_DRAWING'];
    sKUBRAND = json['SKU_BRAND'];
    aREAINFO = json['AREAINFO'].cast<String>();
    sKUCATCODE = json['SKU_CATCODE'];
    sKUTYPE = json['SKU_TYPE'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['SKU_RANGE'] = sKURANGE;
    data['SKU_IMAGE'] = sKUIMAGE;
    data['SKU_CATEGORY'] = sKUCATEGORY;
    data['SKU_USP'] = sKUUSP;
    data['SKU_PRODUCT_CAT'] = sKUPRODUCTCAT;
    data['SKU_DESCRIPTION'] = sKUDESCRIPTION;
    if (cOMPLEMENTARY != null) {
      data['COMPLEMENTARY'] =
          cOMPLEMENTARY!.map((v) => v.toJson()).toList();
    }
    data['SKU_MRP'] = sKUMRP;
    data['SKU_CODE'] = sKUCODE;
    data['SKU_SRP'] = sKUSRP;
    data['SKU_DRAWING'] = sKUDRAWING;
    data['SKU_BRAND'] = sKUBRAND;
    data['AREAINFO'] = aREAINFO;
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