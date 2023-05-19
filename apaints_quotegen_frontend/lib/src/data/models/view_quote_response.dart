class ViewQuoteResponse {
  String? statusMessage;
  String? status;

  ViewQuoteResponse({this.statusMessage, this.status});

  ViewQuoteResponse.fromJson(Map<String, dynamic> json) {
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
