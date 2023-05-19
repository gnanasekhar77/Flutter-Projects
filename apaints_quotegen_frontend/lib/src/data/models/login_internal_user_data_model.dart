class LoginInternalUserDataModel {
  Userinfo? userinfo;
  String? statusMessage;
  String? token;
  String? status;

  LoginInternalUserDataModel(
      {this.userinfo, this.statusMessage, this.token, this.status});

  LoginInternalUserDataModel.fromJson(Map<String, dynamic> json) {
    userinfo =
        json['userinfo'] != null ? Userinfo.fromJson(json['userinfo']) : null;
    statusMessage = json['statusMessage'];
    token = json['token'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (userinfo != null) {
      data['userinfo'] = userinfo!.toJson();
    }
    data['statusMessage'] = statusMessage;
    data['token'] = token;
    data['status'] = status;
    return data;
  }
}

class Userinfo {
  String? empid;
  String? role;
  String? phone;
  String? email;
  String? isExist;
  String? username;

  Userinfo(
      {this.empid,
      this.role,
      this.phone,
      this.email,
      this.isExist,
      this.username});

  Userinfo.fromJson(Map<String, dynamic> json) {
    empid = json['empid'];
    role = json['role'];
    phone = json['phone'];
    email = json['email'];
    isExist = json['isExist'];
    username = json['username'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['empid'] = empid;
    data['role'] = role;
    data['phone'] = phone;
    data['email'] = email;
    data['isExist'] = isExist;
    data['username'] = username;
    return data;
  }
}
