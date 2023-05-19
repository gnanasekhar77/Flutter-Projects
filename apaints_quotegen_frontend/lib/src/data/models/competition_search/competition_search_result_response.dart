class CompetitionSearchResultResponse {
  Bundleinfo1? bundleinfo1;
  Bundleinfo1? bundleinfo2;
  List<CompetitionSearchResultData>? data;
  String? range1Desc;
  String? range2Name;
  String? range2Desc;
  String? range1Name;
  String? statusMessage;
  String? status;

  CompetitionSearchResultResponse(
      {this.bundleinfo1,
      this.bundleinfo2,
      this.data,
      this.range1Desc,
      this.range2Name,
      this.range2Desc,
      this.range1Name,
      this.statusMessage,
      this.status});

  CompetitionSearchResultResponse.fromJson(Map<String, dynamic> json) {
    bundleinfo1 = json['bundleinfo1'] != null
        ? Bundleinfo1.fromJson(json['bundleinfo1'])
        : null;
    bundleinfo2 = json['bundleinfo2'] != null
        ? Bundleinfo1.fromJson(json['bundleinfo2'])
        : null;
    if (json['data'] != null) {
      data = <CompetitionSearchResultData>[];
      json['data'].forEach((v) {
        data?.add(CompetitionSearchResultData.fromJson(v));
      });
    }
    range1Desc = json['range1Desc'];
    range2Name = json['range2Name'];
    range2Desc = json['range2Desc'];
    range1Name = json['range1Name'];
    statusMessage = json['statusMessage'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (bundleinfo1 != null) {
      data['bundleinfo1'] = bundleinfo1?.toJson();
    }
    if (bundleinfo2 != null) {
      data['bundleinfo2'] = bundleinfo2?.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data?.map((v) => v.toJson()).toList();
    }
    data['range1Desc'] = range1Desc;
    data['range2Name'] = range2Name;
    data['range2Desc'] = range2Desc;
    data['range1Name'] = range1Name;
    data['statusMessage'] = statusMessage;
    data['status'] = status;
    return data;
  }
}

class Bundleinfo1 {
  List<String>? sanware;
  List<String>? bundle;

  Bundleinfo1({this.sanware, this.bundle});

  Bundleinfo1.fromJson(Map<String, dynamic> json) {
    sanware = json['sanware'].cast<String>();
    bundle = json['bundle'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['sanware'] = sanware;
    data['bundle'] = bundle;
    return data;
  }
}

class CompetitionSearchResultData {
  CODE2SKUDATA? cODE2SKUDATA;
  COMPSKUDATA? cOMPSKUDATA;
  CODE2SKUDATA? cODE1SKUDATA;

  CompetitionSearchResultData({this.cODE2SKUDATA, this.cOMPSKUDATA, this.cODE1SKUDATA});

  CompetitionSearchResultData.fromJson(Map<String, dynamic> json) {
    cODE2SKUDATA = json['CODE2SKUDATA'] != null
        ? CODE2SKUDATA.fromJson(json['CODE2SKUDATA'])
        : null;
    cOMPSKUDATA = json['COMPSKUDATA'] != null
        ? COMPSKUDATA.fromJson(json['COMPSKUDATA'])
        : null;
    cODE1SKUDATA = json['CODE1SKUDATA'] != null
        ? CODE2SKUDATA.fromJson(json['CODE1SKUDATA'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (cODE2SKUDATA != null) {
      data['CODE2SKUDATA'] = cODE2SKUDATA?.toJson();
    }
    if (cOMPSKUDATA != null) {
      data['COMPSKUDATA'] = cOMPSKUDATA?.toJson();
    }
    if (cODE1SKUDATA != null) {
      data['CODE1SKUDATA'] = cODE1SKUDATA?.toJson();
    }
    return data;
  }
}

class CODE2SKUDATA {
  String? cATCODE;
  String? sKURANGE;
  String? sKUMRP;
  String? sKUCODE;
  String? sKUIMAGE;
  String? sKUCATEGORY;
  String? sKUBRAND;
  List<AREAINFO>? aREAINFO;
  String? sKUDESCRIPTION;
  String? sKUTYPE;

  CODE2SKUDATA(
      {this.cATCODE,
      this.sKURANGE,
      this.sKUMRP,
      this.sKUCODE,
      this.sKUIMAGE,
      this.sKUCATEGORY,
      this.sKUBRAND,
      this.aREAINFO,
      this.sKUDESCRIPTION,
      this.sKUTYPE});

  CODE2SKUDATA.fromJson(Map<String, dynamic> json) {
    cATCODE = json['CAT_CODE'];
    sKURANGE = json['SKU_RANGE'];
    sKUMRP = json['SKU_MRP'];
    sKUCODE = json['SKU_CODE'];
    sKUIMAGE = json['SKU_IMAGE'];
    sKUCATEGORY = json['SKU_CATEGORY'];
    sKUBRAND = json['SKU_BRAND'];
    if (json['AREAINFO'] != null) {
      aREAINFO = <AREAINFO>[];
      json['AREAINFO'].forEach((v) {
        aREAINFO?.add(AREAINFO.fromJson(v));
      });
    }
    sKUDESCRIPTION = json['SKU_DESCRIPTION'];
    sKUTYPE = json['SKU_TYPE'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['CAT_CODE'] = cATCODE;
    data['SKU_RANGE'] = sKURANGE;
    data['SKU_MRP'] = sKUMRP;
    data['SKU_CODE'] = sKUCODE;
    data['SKU_IMAGE'] = sKUIMAGE;
    data['SKU_CATEGORY'] = sKUCATEGORY;
    data['SKU_BRAND'] = sKUBRAND;
    if (aREAINFO != null) {
      data['AREAINFO'] = aREAINFO?.map((v) => v.toJson()).toList();
    }
    data['SKU_DESCRIPTION'] = sKUDESCRIPTION;
    data['SKU_TYPE'] = sKUTYPE;
    return data;
  }
}

class AREAINFO {
  String? aREA;
  String? qTY;

  AREAINFO({this.aREA, this.qTY});

  AREAINFO.fromJson(Map<String, dynamic> json) {
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

class COMPSKUDATA {
  String? cOMPCATCODE;
  String? iMAGE;
  String? cOMPDESCRIPTION;
  String? cOMPIMAGE;
  String? cOMPMRP;
  String? cOMPSKUTYPE;
  String? cOMPBRAND;
  String? cOMPRANGE;

  COMPSKUDATA(
      {this.cOMPCATCODE,
      this.iMAGE,
      this.cOMPDESCRIPTION,
      this.cOMPIMAGE,
      this.cOMPMRP,
      this.cOMPSKUTYPE,
      this.cOMPBRAND,
      this.cOMPRANGE});

  COMPSKUDATA.fromJson(Map<String, dynamic> json) {
    cOMPCATCODE = json['COMP_CAT_CODE'];
    iMAGE = json['IMAGE'];
    cOMPDESCRIPTION = json['COMP_DESCRIPTION'];
    cOMPIMAGE = json['COMP_IMAGE'];
    cOMPMRP = json['COMP_MRP'];
    cOMPSKUTYPE = json['COMP_SKU_TYPE'];
    cOMPBRAND = json['COMP_BRAND'];
    cOMPRANGE = json['COMP_RANGE'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['COMP_CAT_CODE'] = cOMPCATCODE;
    data['IMAGE'] = iMAGE;
    data['COMP_DESCRIPTION'] = cOMPDESCRIPTION;
    data['COMP_IMAGE'] = cOMPIMAGE;
    data['COMP_MRP'] = cOMPMRP;
    data['COMP_SKU_TYPE'] = cOMPSKUTYPE;
    data['COMP_BRAND'] = cOMPBRAND;
    data['COMP_RANGE'] = cOMPRANGE;
    return data;
  }
}