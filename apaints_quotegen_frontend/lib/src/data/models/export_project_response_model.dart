class ExportProjectResponseModel {
  String? pdfurl;
  String? status;
  int? statusFlag;

  ExportProjectResponseModel({required this.pdfurl, required this.status, required this.statusFlag});

  ExportProjectResponseModel.fromJson(Map<String, dynamic> json) {
    pdfurl = json['pdfurl'];
    status = json['status'];
    statusFlag = json['statusFlag'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['pdfurl'] = pdfurl;
    data['status'] = status;
    data['statusFlag'] = statusFlag;
    return data;
  }
}