import 'package:flutter/material.dart';

class SkuRequestBody {
  List<Quoteinfo>? quoteinfo;
  String? category;
  String? brand;
  String? range;
  String? discountamount;
  String? totalpricewithgst;
  String? quotename;
  String? projectid;
  String? quotetype;
  bool? isExist;
  String? quoteID;
  String? projectName;
  String? contactPerson;
  String? mobileNumber;
  String? siteAddress;
  String? noOfBathRooms;

  SkuRequestBody(
      {this.quoteinfo,
      this.category,
      this.brand,
      this.range,
      this.discountamount,
      this.totalpricewithgst,
      this.quotename,
      this.projectid,
      this.quotetype,
      this.isExist,
      this.quoteID,
      this.projectName,
      this.contactPerson,
      this.mobileNumber,
      this.siteAddress,
      this.noOfBathRooms});

  SkuRequestBody.fromJson(Map<String, dynamic> json) {
    if (json['quoteinfo'] != null) {
      quoteinfo = <Quoteinfo>[];
      json['quoteinfo'].forEach((v) {
        quoteinfo!.add(Quoteinfo.fromJson(v));
      });
    }
    category = json['category'];
    brand = json['brand'];
    range = json['range'];
    discountamount = json['discountamount'];
    totalpricewithgst = json['totalpricewithgst'];
    quotename = json['quotename'];
    projectid = json['projectid'];
    quotetype = json['quotetype'];
    isExist = json['isExist'];
    quoteID = json['quoteid'];
    projectName = json['project_name'];
    contactPerson = json['contact_person'];
    mobileNumber = json['mobile_number'];
    siteAddress = json['site_address'];
    noOfBathRooms = json['no_of_bath_rooms'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (quoteinfo != null) {
      data['quoteinfo'] = quoteinfo!.map((v) => v.toJson()).toList();
    }
    data['category'] = category;
    data['brand'] = brand;
    data['range'] = range;
    data['discountamount'] = discountamount;
    data['totalpricewithgst'] = totalpricewithgst;
    data['quotename'] = quotename;
    data['projectid'] = projectid;
    data['quotetype'] = quotetype;
    data['isExist'] = isExist;
    data['quoteid'] = quoteID;
    data['project_name'] = projectName;
    data['contact_person'] = contactPerson;
    data['mobile_number'] = mobileNumber;
    data['site_address'] = siteAddress;
    data['no_of_bath_rooms'] = noOfBathRooms;
    return data;
  }
}

class Quoteinfo {
  String? skuid;
  String? discount;
  String? totalqty;
  List<Area>? area;
  String? totalprice;
  String? bundletype;
  String? netDiscount;

  Quoteinfo(
      {this.skuid,
      this.discount,
      this.totalqty,
      this.area,
      this.totalprice,
      this.bundletype});

  Quoteinfo.fromJson(Map<String, dynamic> json) {
    skuid = json['skuid'];
    discount = json['discount'];
    totalqty = json['totalqty'];
    if (json['area'] != '' && json['area'] != null) {
      area = <Area>[];
      json['area'].forEach((v) {
        area!.add(Area.fromJson(v));
      });
    }
    totalprice = json['totalprice'];
    bundletype = json['bundletype'];
    netDiscount = json['netdiscount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['skuid'] = skuid;
    data['discount'] = discount;
    data['totalqty'] = totalqty;
    if (area != null) {
      data['area'] = area!.map((v) => v.toJson()).toList();
    }
    data['totalprice'] = totalprice;
    data['bundletype'] = bundletype;
    data['netdiscount'] = netDiscount;
    return data;
  }
}

class Area {
  String? areaname;
  String? areaqty;
  TextEditingController? areaqtyController;

  Area({this.areaname, this.areaqty});

  Area.fromJson(Map<String, dynamic> json) {
    areaname = json['areaname'];
    areaqty = json['areaqty'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['areaname'] = areaname;
    data['areaqty'] = areaqty;
    return data;
  }
}
