
class ErrorDetails {
  ErrorDetails({
    this.errorCode,
    this.errorDesc,
    this.errorDetails
  });

  String? errorCode;
  String? errorDesc;
  String? errorDetails;


  factory ErrorDetails.fromJson(Map<String, dynamic> json) => ErrorDetails(
    errorCode:
    json["errorCode"],
    errorDesc:
    json["errorDesc"],
    errorDetails: json["errorDetails"],
  );

  Map<String, dynamic> toJson() => {
    "errorCode": errorCode,
    "errorDesc": errorDesc,
    "errorDetails": errorDetails,
  };
}