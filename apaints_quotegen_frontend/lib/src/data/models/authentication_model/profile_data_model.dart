import 'dart:convert';

class ProfileDataModel {
  String? email;
  String? phone;
  bool? isRegistered;
  String? name;
  ProfileDataModel({
    this.email,
    this.phone,
    this.isRegistered,
    this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'phone': phone,
      'isRegistered': isRegistered,
      'name': name,
    };
  }

  factory ProfileDataModel.fromMap(Map<String, dynamic> map) {
    return ProfileDataModel(
      email: map['email'],
      phone: map['phone'],
      isRegistered: map['isRegistered'],
      name: map['name'],
    );
  }

  String toJson() => json.encode(toMap());

  factory ProfileDataModel.fromJson(String source) =>
      ProfileDataModel.fromMap(json.decode(source));

  @override
  String toString() {
    // ignore: lines_longer_than_80_chars
    return 'ProfileDataModel(email: $email, phone: $phone, isRegistered: $isRegistered, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProfileDataModel &&
        other.email == email &&
        other.phone == phone &&
        other.isRegistered == isRegistered &&
        other.name == name;
  }

  @override
  int get hashCode {
    return email.hashCode ^
        phone.hashCode ^
        isRegistered.hashCode ^
        name.hashCode;
  }
}
