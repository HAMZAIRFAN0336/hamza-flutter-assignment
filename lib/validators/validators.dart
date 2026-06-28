/// Pure-Dart form validators. No Flutter imports here on purpose so this
/// class can be unit tested without a widget tree.
class Validators {
  Validators._();

  static String? validateEmpty(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName cannot be empty';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    final emptyError = validateEmpty(value, fieldName: 'Email');
    if (emptyError != null) return emptyError;

    final emailRegex = RegExp(r'^[\w.\-]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!emailRegex.hasMatch(value!.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Requires at least 8 characters, one uppercase letter, and one
  /// special character.
  static String? validatePassword(String? value) {
    final emptyError = validateEmpty(value, fieldName: 'Password');
    if (emptyError != null) return emptyError;

    final password = value!;
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'''[!@#$%^&*(),.?":{}|<>_\-+=\[\]/~`]''').hasMatch(password)) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  static String? validateMatch(String? value, String original, {String fieldName = 'Fields'}) {
    final emptyError = validateEmpty(value, fieldName: fieldName);
    if (emptyError != null) return emptyError;

    if (value != original) {
      return 'Passwords do not match';
    }
    return null;
  }
}
