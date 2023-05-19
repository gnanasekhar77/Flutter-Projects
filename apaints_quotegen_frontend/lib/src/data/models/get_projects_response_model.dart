import 'package:APaints_QGen/src/core/utils/logger.dart';

class GetProjectsResponseModel {
   List<ProjectData>? data;
  int? numofpages;
  int? totalrows;
   String? statusMessage;
   String? status;

  GetProjectsResponseModel(
      {required this.data,this.numofpages,
      this.totalrows, required this.statusMessage, required this.status});

  GetProjectsResponseModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <ProjectData>[];
      json['data'].forEach((v) {
        data?.add(ProjectData.fromJson(v));
      });
    }
    numofpages = json['numofpages'];
    totalrows = json['totalrows'];
    statusMessage = json['statusMessage'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['data'] = this.data?.map((v) => v.toJson()).toList();
    data['numofpages'] = numofpages;
    data['totalrows'] = totalrows;
    data['statusMessage'] = statusMessage;
    data['status'] = status;
    return data;
  }
}

class ProjectData {
  String? cONTACTPERSON;
  String? sITEADDRESS;
  String? nOOFBATHROOMS;
  String? pROJECTID;
  String? mOBILENUMBER;
  String? pROJECTNAME;

  ProjectData(
      {this.cONTACTPERSON,
      this.sITEADDRESS,
      this.nOOFBATHROOMS,
      this.pROJECTID,
      this.mOBILENUMBER,
      this.pROJECTNAME});

  ProjectData.fromJson(Map<String, dynamic> json) {
    cONTACTPERSON = json['CONTACTPERSON'];
    sITEADDRESS = json['SITEADDRESS'];
    nOOFBATHROOMS = json['NOOFBATHROOMS'];
    pROJECTID = json['PROJECTID'];
    mOBILENUMBER = json['MOBILENUMBER'];
    pROJECTNAME = json['PROJECTNAME'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['CONTACTPERSON'] = cONTACTPERSON;
    data['SITEADDRESS'] = sITEADDRESS;
    data['NOOFBATHROOMS'] = nOOFBATHROOMS;
    data['PROJECTID'] = pROJECTID;
    data['MOBILENUMBER'] = mOBILENUMBER;
    data['PROJECTNAME'] = pROJECTNAME;
    return data;
  }
}
