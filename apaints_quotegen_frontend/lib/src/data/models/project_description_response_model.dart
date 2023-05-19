import 'package:APaints_QGen/src/data/models/sku_request_model.dart';

class GetProjectDescriptionModel {
  List<Data>? data;
  String? statusMessage;
  String? status;

  GetProjectDescriptionModel({this.data, this.statusMessage, this.status});

  GetProjectDescriptionModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
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

class Data {
  String? cONTACTPERSON;
  String? sITEADDRESS;
  String? nOOFBATHROOMS;
  String? pROJECTID;
  List<QUOTEINFO>? qUOTEINFO;
  String? mOBILENUMBER;
  String? pROJECTNAME;

  Data(
      {this.cONTACTPERSON,
      this.sITEADDRESS,
      this.nOOFBATHROOMS,
      this.pROJECTID,
      this.qUOTEINFO,
      this.mOBILENUMBER,
      this.pROJECTNAME});

  Data.fromJson(Map<String, dynamic> json) {
    cONTACTPERSON = json['CONTACTPERSON'];
    sITEADDRESS = json['SITEADDRESS'];
    nOOFBATHROOMS = json['NOOFBATHROOMS'];
    pROJECTID = json['PROJECTID'];
    if (json['QUOTEINFO'] != null) {
      qUOTEINFO = <QUOTEINFO>[];
      json['QUOTEINFO'].forEach((v) {
        qUOTEINFO!.add(QUOTEINFO.fromJson(v));
      });
    }
    mOBILENUMBER = json['MOBILENUMBER'];
    pROJECTNAME = json['PROJECTNAME'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['CONTACTPERSON'] = cONTACTPERSON;
    data['SITEADDRESS'] = sITEADDRESS;
    data['NOOFBATHROOMS'] = nOOFBATHROOMS;
    data['PROJECTID'] = pROJECTID;
    if (qUOTEINFO != null) {
      data['QUOTEINFO'] = qUOTEINFO!.map((v) => v.toJson()).toList();
    }
    data['MOBILENUMBER'] = mOBILENUMBER;
    data['PROJECTNAME'] = pROJECTNAME;
    return data;
  }
}

class QUOTEINFO {
  String? quotename;
  List<Projectdetails>? projectdetails;
  String? skudiscount;
  String? discountamount;
  String? totalqty;
  String? totalprice;
  String? range;
  String? bundletype;
  String? totalwithgst;
  String? category;
  String? brand;
  String? projectid;
  String? quoteid;
  List<String>? fliprange;
  bool? isFlipAvailable;

  QUOTEINFO({
    this.quotename,
    this.projectdetails,
    this.skudiscount,
    this.discountamount,
    this.totalqty,
    this.totalprice,
    this.range,
    this.bundletype,
    this.totalwithgst,
    this.category,
    this.brand,
    this.projectid,
    this.quoteid,
    this.fliprange,
    this.isFlipAvailable,
  });

  QUOTEINFO.fromJson(Map<String, dynamic> json) {
    quotename = json['quotename'];
    if (json['projectdetails'] != null) {
      projectdetails = <Projectdetails>[];
      (json['projectdetails'] ?? []).forEach((v) {
        projectdetails?.add(Projectdetails.fromJson(v));
      });
    }
    skudiscount = json['skudiscount'];
    discountamount = json['discountamount'];
    totalqty = json['totalqty'];
    totalprice = json['totalprice'];
    range = json['range'];
    bundletype = json['bundletype'];
    totalwithgst = json['totalwithgst'];
    category = json['category'];
    brand = json['brand'];
    projectid = json['projectid'];
    quoteid = json['quoteid'];
    if (json['fliprange'] != null) {
      fliprange = <String>[];
      json['fliprange'].forEach((v) {
        fliprange?.add(v);
      });
    }
    isFlipAvailable = json['isFlip'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['quotename'] = quotename;
    if (projectdetails != null) {
      data['projectdetails'] = projectdetails!.map((v) => v.toJson()).toList();
    }
    data['skudiscount'] = skudiscount;
    data['discountamount'] = discountamount;
    data['totalqty'] = totalqty;
    data['totalprice'] = totalprice;
    data['range'] = range;
    data['bundletype'] = bundletype;
    data['totalwithgst'] = totalwithgst;
    data['category'] = category;
    data['brand'] = brand;
    data['projectid'] = projectid;
    data['quoteid'] = quoteid;
    data['fliprange'] = fliprange;
    data['isFlip'] = isFlipAvailable;

    return data;
  }
}

class Projectdetails {
  String? sKURANGE;
  String? sKUIMAGE;
  String? tOTALPRICE;
  String? sKUCATEGORY;
  String? sKUUSP;
  List<Area>? aREADATA;
  String? qUOTESKUID;
  String? sKUPRODUCTCAT;
  String? sKUDESCRIPTION;
  String? sKUDISCOUNT;
  String? tOTALQTY;
  String? qUOTEID;
  String? sKUMRP;
  String? sKUCODE;
  String? sKUSRP;
  String? sKUDRAWING;
  String? sKUBRAND;
  String? sKUCATCODE;
  String? sKUTYPE;
  List<Area>? areaInfo = [];
  int? discount;
  String? quantity;
  String? totalPrice;
  int? totalPriceAfterDiscount = 0;
  int? index;
  String? SKUPREDISCOUNT;
  double? discPrice = 0;

  Projectdetails(
      {this.sKURANGE,
      this.sKUIMAGE,
      this.tOTALPRICE,
      this.sKUCATEGORY,
      this.sKUUSP,
      this.aREADATA,
      this.qUOTESKUID,
      this.sKUPRODUCTCAT,
      this.sKUDESCRIPTION,
      this.sKUDISCOUNT,
      this.tOTALQTY,
      this.qUOTEID,
      this.sKUMRP,
      this.sKUCODE,
      this.sKUSRP,
      this.sKUDRAWING,
      this.sKUBRAND,
      this.sKUCATCODE,
      this.sKUTYPE,
      this.discount,
      this.quantity,
      this.totalPrice,
      this.totalPriceAfterDiscount,
      this.SKUPREDISCOUNT,
      this.discPrice
      });

  Projectdetails.fromJson(Map<String, dynamic> json) {
    sKURANGE = json['SKU_RANGE'];
    sKUIMAGE = json['SKU_IMAGE'];
    tOTALPRICE = json['TOTALPRICE'];
    sKUCATEGORY = json['SKU_CATEGORY'];
    sKUUSP = json['SKU_USP'];
    if (json['AREADATA'] != '' && json['AREADATA'] != null) {
      aREADATA = <Area>[];
      json['AREADATA'].forEach((v) {
        aREADATA!.add(Area.fromJson(v));
      });
    }
    qUOTESKUID = json['QUOTESKUID'];
    sKUPRODUCTCAT = json['SKU_PRODUCT_CAT'];
    sKUDESCRIPTION = json['SKU_DESCRIPTION'];
    sKUDISCOUNT = json['SKUDISCOUNT'];
    tOTALQTY = json['TOTALQTY'];
    qUOTEID = json['QUOTEID'];
    sKUMRP = json['SKU_MRP'];
    sKUCODE = json['SKU_CODE'];
    sKUSRP = json['SKU_SRP'];
    sKUDRAWING = json['SKU_DRAWING'];
    sKUBRAND = json['SKU_BRAND'];
    sKUCATCODE = json['SKU_CATCODE'];
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
    SKUPREDISCOUNT = json['SKUPREDISCOUNT'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    Map<String, dynamic> toJson() {
      final Map<String, dynamic> data = <String, dynamic>{};
      data['SKU_RANGE'] = sKURANGE;
      data['SKU_IMAGE'] = sKUIMAGE;
      data['TOTALPRICE'] = tOTALPRICE;
      data['SKU_CATEGORY'] = sKUCATEGORY;
      data['SKU_USP'] = sKUUSP;
      if (aREADATA != null) {
        data['AREADATA'] = aREADATA!.map((v) => v.toJson()).toList();
      }
      data['QUOTESKUID'] = qUOTESKUID;
      data['SKU_PRODUCT_CAT'] = sKUPRODUCTCAT;
      data['SKU_DESCRIPTION'] = sKUDESCRIPTION;
      data['SKUDISCOUNT'] = sKUDISCOUNT;
      data['TOTALQTY'] = tOTALQTY;
      data['QUOTEID'] = qUOTEID;
      data['SKU_MRP'] = sKUMRP;
      data['SKU_CODE'] = sKUCODE;
      data['SKU_SRP'] = sKUSRP;
      data['SKU_DRAWING'] = sKUDRAWING;
      data['SKU_BRAND'] = sKUBRAND;
      data['SKU_CATCODE'] = sKUCATCODE;
      data['SKU_TYPE'] = sKUTYPE;
      data['DISCOUNT'] = discount;
      data['QUANTITY'] = quantity;
      data['TOTALPRICE'] = totalPrice;
      data['TOTALPRICEAFTERDISCOUNT'] = totalPriceAfterDiscount;
      if (areaInfo != null) {
        data['AREAINFOBJ'] = areaInfo?.map((v) => v.toJson()).toList();
      }
      data['SKUPREDISCOUNT'] = SKUPREDISCOUNT;
      return data;
    }

    return data;
  }
}

class AREADATA {
  String? aREAQTY;
  String? aREANAME;

  AREADATA({this.aREAQTY, this.aREANAME});

  AREADATA.fromJson(Map<String, dynamic> json) {
    aREAQTY = json['AREAQTY'];
    aREANAME = json['AREANAME'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['AREAQTY'] = this.aREAQTY;
    data['AREANAME'] = this.aREANAME;
    return data;
  }
}
