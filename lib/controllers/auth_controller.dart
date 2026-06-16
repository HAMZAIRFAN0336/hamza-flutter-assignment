import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../enums/auth_state.dart';
import '../enums/gender.dart';
import '../models/user.dart';

/// Plain Dart controller — no state management package required.
///
/// Design notes:
/// - The "registered" user lives in memory for the session (no database,
///   no backend, as per the assignment constraints).
/// - "Remember Me" is the one exception that touches SharedPreferences:
///   when checked, the user's data is persisted so the app can log them
///   back in automatically after a restart, even though the in-memory
///   `_registeredUser` would otherwise be empty on a fresh launch.
class AuthController {
  AuthController._internal();
  static final AuthController instance = AuthController._internal();

  User? _registeredUser;
  AuthState _authState = AuthState.unauthenticated;

  static const _kRememberMeKey = 'remember_me';
  static const _kUserKey = 'remembered_user';

  User? get registeredUser => _registeredUser;
  AuthState get authState => _authState;

  /// Stores the newly registered user in memory (single-user demo app).
  void register(User user) {
    _registeredUser = user;
  }

  /// Checks the given credentials against the in-memory registered user.
  /// Returns the matching [User] on success, or null on failure.
  User? login({required String email, required String password}) {
    final user = _registeredUser;
    if (user == null) {
      _authState = AuthState.unauthenticated;
      return null;
    }

    final emailMatches = user.email.trim().toLowerCase() == email.trim().toLowerCase();
    final passwordMatches = user.password == password;

    if (emailMatches && passwordMatches) {
      _authState = AuthState.authenticated;
      return user;
    }

    _authState = AuthState.unauthenticated;
    return null;
  }

  /// Persists (or clears) the Remember Me session in SharedPreferences.
  Future<void> setRememberMe(bool remember, User user) async {
    final prefs = await SharedPreferences.getInstance();
    if (remember) {
      await prefs.setBool(_kRememberMeKey, true);
      await prefs.setString(_kUserKey, jsonEncode(_userToMap(user)));
    } else {
      await prefs.setBool(_kRememberMeKey, false);
      await prefs.remove(_kUserKey);
    }
  }

  /// Call on app start (e.g. from the Login screen's initState). If a
  /// Remember Me session exists, rehydrates the in-memory user and
  /// returns it so the caller can skip straight to the Dashboard.
  Future<User?> tryAutoLogin() async {
    _authState = AuthState.loading;
    final prefs = await SharedPreferences.getInstance();
    final remembered = prefs.getBool(_kRememberMeKey) ?? false;

    if (!remembered) {
      _authState = AuthState.unauthenticated;
      return null;
    }

    final userJson = prefs.getString(_kUserKey);
    if (userJson == null) {
      _authState = AuthState.unauthenticated;
      return null;
    }

    final map = jsonDecode(userJson) as Map<String, dynamic>;
    final user = _userFromMap(map);
    _registeredUser ??= user;
    _authState = AuthState.authenticated;
    return user;
  }

  /// Logs out and clears any remembered session.
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kRememberMeKey, false);
    await prefs.remove(_kUserKey);
    _authState = AuthState.unauthenticated;
  }

  Map<String, dynamic> _userToMap(User user) => {
        'firstName': user.firstName,
        'lastName': user.lastName,
        'email': user.email,
        'gender': user.gender.name,
        'password': user.password,
      };

  User _userFromMap(Map<String, dynamic> map) => User(
        firstName: map['firstName'] as String,
        lastName: map['lastName'] as String,
        email: map['email'] as String,
        gender: Gender.values.byName(map['gender'] as String),
        password: map['password'] as String,
      );
}
