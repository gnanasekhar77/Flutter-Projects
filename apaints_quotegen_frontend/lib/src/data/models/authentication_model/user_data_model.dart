import 'dart:convert';

import 'package:APaints_QGen/src/data/models/authentication_model/profile_data_model.dart';

class UserDataModel {
  ProfileDataModel? profile;
  String? token;
  UserDataModel({
    this.profile,
    this.token,
  });

  Map<String, dynamic> toMap() {
    return {
      'profile': profile?.toMap(),
      'token': token,
    };
  }

  factory UserDataModel.fromMap(Map<String, dynamic> map) {
    return UserDataModel(
      profile: map['profile'] != null
          ? ProfileDataModel.fromMap(map['profile'])
          : null,
      token: map['token'],
    );
  }

  String toJson() => json.encode(toMap());

  factory UserDataModel.fromJson(String source) =>
      UserDataModel.fromMap(json.decode(source));

  @override
  String toString() => 'UserDataModel(profile: $profile, token: $token)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserDataModel &&
        other.profile == profile &&
        other.token == token;
  }

  @override
  int get hashCode => profile.hashCode ^ token.hashCode;
}
