class CompetitionSearchListResponse {
  List<Data>? data;
  String? statusMessage;
  String? status;

  CompetitionSearchListResponse({required this.data, required this.statusMessage,required this.status});

  CompetitionSearchListResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data?.add(Data.fromJson(v));
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
    data['statusMessage'] = statusMessage;
    data['status'] = status;
    return data;
  }
}

class Data {
  String? bRANDNAME;
  List<String>? rANGE;

  Data({required this.bRANDNAME,required this.rANGE});

  Data.fromJson(Map<String, dynamic> json) {
    bRANDNAME = json['BRANDNAME'];
    rANGE = json['RANGE'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['BRANDNAME'] = bRANDNAME;
    data['RANGE'] = rANGE;
    return data;
  }
}