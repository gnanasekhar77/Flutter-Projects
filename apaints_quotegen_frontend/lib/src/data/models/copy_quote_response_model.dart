class CopyQuoteResponse {
  String? statusMessage;
  String? status;

  CopyQuoteResponse({this.statusMessage, this.status});

  CopyQuoteResponse.fromJson(Map<String, dynamic> json) {
    statusMessage = json['statusMessage'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['statusMessage'] = statusMessage;
    data['status'] = status;
    return data;
  }
}