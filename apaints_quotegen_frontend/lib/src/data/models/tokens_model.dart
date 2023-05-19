// ignore_for_file: prefer_if_null_operators

import 'dart:convert';

TokensModel getTokenModelFromJson(String str) =>
    TokensModel.fromJson(json.decode(str));

String getTokenModelToJson(TokensModel data) => json.encode(data.toJson());

class TokensModel {
  TokensModel({
    this.statusCode,
    this.statusMessage,
  });

  String? statusCode;

  String? statusMessage;

  factory TokensModel.fromJson(Map<String, dynamic> json) => TokensModel(
        statusCode: json["status"] == null ? null : json["status"],
        statusMessage:
            json["statusMessage"] == null ? null : json["statusMessage"],
      );

  Map<String, dynamic> toJson() => {
        "status": statusCode == null ? null : statusCode,
        "statusMessage": statusMessage == null ? null : statusMessage,
      };
}
