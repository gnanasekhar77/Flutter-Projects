// ignore_for_file: prefer_if_null_operators

import 'dart:convert';

import 'package:APaints_QGen/src/data/models/token_model/error_detail_model.dart';

GetTokenModel getTokenModelFromJson(String str) =>
    GetTokenModel.fromJson(json.decode(str));

String getTokenModelToJson(GetTokenModel data) => json.encode(data.toJson());

class GetTokenModel {
  GetTokenModel({
    this.statusCode,
    this.statusFlag,
    this.errorDetails,
    this.accessToken,
  });

  int? statusCode;
  bool? statusFlag;
  ErrorDetails? errorDetails;
  String? accessToken;

  factory GetTokenModel.fromJson(Map<String, dynamic> json) => GetTokenModel(
        statusCode: json["statusCode"] == null ? null : json["statusCode"],
        statusFlag: json["statusFlag"] == null ? null : json["statusFlag"],
        errorDetails:
            json["errorDetails"] == null ? null : json["errorDetails"],
        accessToken: json["accessToken"] == null ? null : json["accessToken"],
      );

  Map<String, dynamic> toJson() => {
        "statusCode": statusCode == null ? null : statusCode,
        "statusFlag": statusFlag == null ? null : statusFlag,
        "errorDetails": errorDetails == null ? null : errorDetails,
        "accessToken": accessToken == null ? null : accessToken,
      };
}
