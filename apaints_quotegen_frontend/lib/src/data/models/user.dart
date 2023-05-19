import 'package:flutter/material.dart';


class User {
  final String id;
  final String email;
  final bool isEmailVerified;
  const User({
    required this.id,
    required this.email,
    required this.isEmailVerified,
  });
}
