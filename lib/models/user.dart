import '../enums/gender.dart';

class User {
  final String firstName;
  final String lastName;
  final String email;
  final Gender gender;
  final String password;

  User({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.gender,
    required this.password,
  });

  String get fullName => '$firstName $lastName';

  /// Two-letter initials used for the avatar placeholder.
  String get initials {
    final first = firstName.isNotEmpty ? firstName[0] : '';
    final last = lastName.isNotEmpty ? lastName[0] : '';
    return '$first$last'.toUpperCase();
  }
}
