class DeleteQuoteResponse {
  String? statusMessage;
  String? status;

  DeleteQuoteResponse({this.statusMessage, this.status});

  DeleteQuoteResponse.fromJson(Map<String, dynamic> json) {
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
