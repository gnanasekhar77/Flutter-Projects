// ignore_for_file: prefer_if_null_operators

import 'dart:convert';

LoginModel loginModelFromJson(String str) =>
    LoginModel.fromJson(json.decode(str));

String loginModelToJson(LoginModel data) => json.encode(data.toJson());

class LoginModel {
  LoginModel(
      {this.userLevel,
      this.userPhoto,
      this.usertoken,
      this.userid,
      this.statusMessage,
      this.status,
      this.statusFlag,
      this.userName});

  int? userLevel;
  String? userPhoto;
  String? usertoken;
  String? userid;
  String? statusMessage;
  String? status;
  int? statusFlag;
  String? userName;

  factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
      userLevel: json["userlevel"] == null ? null : json["userlevel"],
      userPhoto: json["userphoto"] == null ? null : json["userphoto"],
      usertoken: json["usertoken"] == null ? null : json["usertoken"],
      userid: json["userid"] == null ? null : json["userid"],
      statusMessage:
          json["statusMessage"] == null ? null : json["statusMessage"],
      status: json["status"] == null ? null : json["status"],
      statusFlag: json["statusFlag"] == null ? null : json["statusFlag"],
      userName: json["username"] == null ? null : json["username"]);

  Map<String, dynamic> toJson() => {
        "userlevel": userLevel == null ? null : userLevel,
        "userphoto": userPhoto == null ? null : userPhoto,
        "usertoken": usertoken == null ? null : usertoken,
        "userid": userid == null ? null : userid,
        "statusMessage": statusMessage == null ? null : statusMessage,
        "status": status == null ? null : status,
        "statusFlag": statusFlag == null ? null : statusFlag,
        "username": userName == null ? null : userName
      };
}
