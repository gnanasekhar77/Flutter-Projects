class TemplateQuoteListResponse {
  List<Rangesdata>? rangesdata;
  List<Data>? data;
  String? success;
  String? statusMessage;

  TemplateQuoteListResponse({this.data, this.success, this.statusMessage});

  TemplateQuoteListResponse.fromJson(Map<String, dynamic> json) {
    if (json['rangesdata'] != null) {
      rangesdata = <Rangesdata>[];
      json['rangesdata'].forEach((v) {
        rangesdata?.add(Rangesdata.fromJson(v));
      });
    }
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data?.add(Data.fromJson(v));
      });
    }
    success = json['success'];
    statusMessage = json['statusMessage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (rangesdata != null) {
      data['rangesdata'] = rangesdata?.map((v) => v.toJson()).toList();
    }
    if (this.data != null) {
      data['data'] = this.data?.map((v) => v.toJson()).toList();
    }
    data['success'] = success;
    data['statusMessage'] = statusMessage;
    return data;
  }
}

class Rangesdata {
  List<String>? bUNDLENAME;
  List<String>? sANWARETYPES;
  String? bUNDLERANGE;

  Rangesdata({this.bUNDLENAME, this.sANWARETYPES, this.bUNDLERANGE});

  Rangesdata.fromJson(Map<String, dynamic> json) {
    bUNDLENAME = json['BUNDLENAME'].cast<String>();
    sANWARETYPES = json['SANWARETYPES'].cast<String>();
    bUNDLERANGE = json['BUNDLERANGE'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['BUNDLENAME'] = bUNDLENAME;
    data['SANWARETYPES'] = sANWARETYPES;
    data['BUNDLERANGE'] = bUNDLERANGE;
    return data;
  }
}

class Data {
  String? bUNDLEBRAND;
  List<BUNDLERANGE>? bUNDLERANGE;

  Data({this.bUNDLEBRAND, this.bUNDLERANGE});

  Data.fromJson(Map<String, dynamic> json) {
    bUNDLEBRAND = json['BUNDLEBRAND'];
    if (json['BUNDLERANGE'] != null) {
      bUNDLERANGE = <BUNDLERANGE>[];
      json['BUNDLERANGE'].forEach((v) {
        bUNDLERANGE?.add(BUNDLERANGE.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['BUNDLEBRAND'] = bUNDLEBRAND;
    if (bUNDLERANGE != null) {
      data['BUNDLERANGE'] = bUNDLERANGE?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BUNDLERANGE {
  List<String>? bUNDLENAME;
  List<String>? sANWARETYPES;
  String? bUNDLERANGE;

  BUNDLERANGE({this.bUNDLENAME, this.sANWARETYPES, this.bUNDLERANGE});

  BUNDLERANGE.fromJson(Map<String, dynamic> json) {
    bUNDLENAME = json['BUNDLENAME'].cast<String>();
    sANWARETYPES = json['SANWARETYPES'].cast<String>();
    bUNDLERANGE = json['BUNDLERANGE'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['BUNDLENAME'] = bUNDLENAME;
    data['SANWARETYPES'] = sANWARETYPES;
    data['BUNDLERANGE'] = bUNDLERANGE;
    return data;
  }
}