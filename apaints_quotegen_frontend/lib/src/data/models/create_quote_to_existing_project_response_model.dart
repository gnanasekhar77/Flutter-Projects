class CreateQuoteToExistingProjectResponseModel {
  String? statusMessage;
  String? status;
  String? projetID;

  CreateQuoteToExistingProjectResponseModel(
      {required this.statusMessage,
      required this.status,
      required this.projetID});

  CreateQuoteToExistingProjectResponseModel.fromJson(
      Map<String, dynamic> json) {
    statusMessage = json['statusMessage'];
    status = json['status'];
    projetID = json['projectid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['statusMessage'] = statusMessage;
    data['status'] = status;
    data['projectid'] = projetID;
    return data;
  }
}
