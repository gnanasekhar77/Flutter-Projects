class FlipQuoteResponse {
  bool? matchedStatus;
  String? matchedtext;
  String? statusMessage;
  String? status;

  FlipQuoteResponse(
      {required this.matchedStatus,
      this.matchedtext,
      required this.statusMessage,
      required this.status});

  FlipQuoteResponse.fromJson(Map<String, dynamic> json) {
    matchedStatus = json['matchedStatus'];
    matchedtext = json['matchedtext'];
    statusMessage = json['statusMessage'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['matchedStatus'] = matchedStatus;
    data['matchedtext'] = matchedtext;
    data['statusMessage'] = statusMessage;
    data['status'] = status;
    return data;
  }
}
