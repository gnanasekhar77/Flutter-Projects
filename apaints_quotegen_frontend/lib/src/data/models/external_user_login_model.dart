class ExternalUserLoginModel {
  String? statusMessage;
  String? status;

  ExternalUserLoginModel({this.statusMessage, this.status});

  ExternalUserLoginModel.fromJson(Map<String, dynamic> json) {
    statusMessage = json['statusMessage'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statusMessage'] = this.statusMessage;
    data['status'] = this.status;
    return data;
  }
}
