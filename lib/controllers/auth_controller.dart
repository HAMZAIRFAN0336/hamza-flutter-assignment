import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../enums/auth_state.dart';
import '../enums/gender.dart';
import '../models/user.dart';

class AuthController {
  AuthController._internal();
  static final AuthController instance = AuthController._internal();

  User? _registeredUser;
  AuthState _authState = AuthState.unauthenticated;

  static const _kRememberMeKey = 'remember_me';
  static const _kUserKey = 'remembered_user';

  // ── New: persistent storage for the registered account itself,
  //         separate from the "Remember Me" session flag. ──
  static const _kRegisteredUserKey = 'registered_user';

  User? get registeredUser => _registeredUser;
  AuthState get authState => _authState;

  /// Registers a new user AND persists it to disk immediately,
  /// so it survives app restarts even without "Remember Me".
  Future<void> register(User user) async {
    _registeredUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kRegisteredUserKey, jsonEncode(_userToMap(user)));
  }

  /// Checks the given credentials. Falls back to disk if the in-memory
  /// user was lost (e.g. after an app restart).
  Future<User?> login({required String email, required String password}) async {
    User? user = _registeredUser;

    // If nothing in memory, try loading the persisted registration.
    if (user == null) {
      final prefs = await SharedPreferences.getInstance();
      final storedJson = prefs.getString(_kRegisteredUserKey);
      if (storedJson != null) {
        final map = jsonDecode(storedJson) as Map<String, dynamic>;
        user = _userFromMap(map);
        _registeredUser = user;
      }
    }

    if (user == null) {
      _authState = AuthState.unauthenticated;
      return null;
    }

    final emailMatches =
        user.email.trim().toLowerCase() == email.trim().toLowerCase();
    final passwordMatches = user.password == password;

    if (emailMatches && passwordMatches) {
      _authState = AuthState.authenticated;
      return user;
    }

    _authState = AuthState.unauthenticated;
    return null;
  }

  /// Persists (or clears) the Remember Me session in SharedPreferences.
  /// This is separate from the registered account itself — it only
  /// controls whether the user is auto-logged-in on next app start.
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

  /// Logs out and clears the Remember Me session.
  /// Note: this does NOT delete the registered account itself —
  /// only the auto-login session. The user can still log back in
  /// manually with their email/password afterward.
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
