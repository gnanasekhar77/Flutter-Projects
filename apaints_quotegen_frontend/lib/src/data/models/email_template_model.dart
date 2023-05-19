class EmailTemplateModel {
  String? status;
  int? statusFlag;

  EmailTemplateModel({this.status, this.statusFlag});

  EmailTemplateModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    statusFlag = json['statusFlag'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['statusFlag'] = statusFlag;
    return data;
  }
}
