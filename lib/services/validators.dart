/// Pure form validators. Each returns null when valid, else a short message.
library;

final RegExp _nameChars = RegExp(r"^[\p{L}][\p{L} '\-]*$", unicode: true);

final RegExp _email = RegExp(
  r"^[a-z0-9!#$%&'*+/=?^_`{|}~-]+(\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*"
  r'@([a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z]{2,63}$',
);

final RegExp _upper = RegExp(r'[A-Z]');
final RegExp _lower = RegExp(r'[a-z]');
final RegExp _digit = RegExp(r'[0-9]');
final RegExp _special = RegExp(r'[^A-Za-z0-9\s]');

/// Compared after lowercasing and dropping symbols, so "Password1!" matches.
const Set<String> kCommonPasswords = {
  'password',
  '12345678',
  '123456789',
  '1234567890',
  'qwerty123',
  'qwertyuiop',
  'password1',
  'password123',
  'iloveyou',
  '11111111',
  '00000000',
  'abc12345',
  'abcd1234',
  'letmein123',
  'welcome1',
  'welcome123',
  'admin123',
  'sunshine1',
  'football1',
  'passw0rd',
};

String normalizeName(String value) => value.trim();

String normalizeEmail(String value) => value.trim().toLowerCase();

String? validateName(String? value) {
  final name = normalizeName(value ?? '');
  if (name.isEmpty) return 'Enter your full name';
  if (name.length < 3) return 'Name must be at least 3 characters';
  if (name.length > 50) return 'Name must be 50 characters or fewer';
  if (!_nameChars.hasMatch(name)) {
    return 'Use letters, spaces, hyphens or apostrophes only';
  }
  return null;
}

String? validateEmail(String? value) {
  final email = normalizeEmail(value ?? '');
  if (email.isEmpty) return 'Enter your email';
  if (email.contains(RegExp(r'\s'))) return 'Email cannot contain spaces';
  if (email.length > 254) return 'Email is too long';
  if (!email.contains('@')) return 'Email must contain @';
  if (email.split('@').first.length > 64 || !_email.hasMatch(email)) {
    return 'Enter a valid email address';
  }
  return null;
}

/// One line of the password checklist shown on the Register screen.
class PasswordRule {
  const PasswordRule(this.label, this.test);

  final String label;
  final bool Function(String password) test;
}

final List<PasswordRule> kPasswordRules = [
  PasswordRule('At least 8 characters', (p) => p.length >= 8),
  PasswordRule(
    'Upper and lower case letters',
    (p) => _upper.hasMatch(p) && _lower.hasMatch(p),
  ),
  PasswordRule('At least one number', (p) => _digit.hasMatch(p)),
  PasswordRule('At least one special character', (p) => _special.hasMatch(p)),
];

bool isCommonPassword(String password) => kCommonPasswords.contains(
  password.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), ''),
);

/// [name] and [email] are optional; when given, the password may not contain
/// the name (or any 3+ letter part of it) or the email's local part.
String? validatePassword(String? value, {String name = '', String email = ''}) {
  final password = value ?? '';
  if (password.isEmpty) return 'Enter a password';
  if (password.length < 8) return 'Use at least 8 characters';
  if (!_upper.hasMatch(password)) return 'Add an uppercase letter';
  if (!_lower.hasMatch(password)) return 'Add a lowercase letter';
  if (!_digit.hasMatch(password)) return 'Add a number';
  if (!_special.hasMatch(password)) return 'Add a special character';
  if (isCommonPassword(password)) return 'This password is too common';

  final lower = password.toLowerCase();
  final nameParts = normalizeName(name).toLowerCase().split(RegExp(r'\s+'));
  final fullName = nameParts.join();
  if (fullName.length >= 3 &&
      (lower.contains(fullName) ||
          nameParts.any((p) => p.length >= 3 && lower.contains(p)))) {
    return 'Password must not contain your name';
  }

  final local = normalizeEmail(email).split('@').first;
  if (local.length >= 3 && lower.contains(local)) {
    return 'Password must not contain your email';
  }
  return null;
}

String? validateConfirmPassword(String? value, String password) {
  if (value == null || value.isEmpty) return 'Confirm your password';
  if (value != password) return 'Passwords do not match';
  return null;
}

/// Login only checks presence; rules apply when the password is created.
String? validateLoginPassword(String? value) =>
    (value == null || value.isEmpty) ? 'Enter your password' : null;

enum PasswordStrength { none, weak, fair, strong }

/// Rules met plus a bonus for 12+ characters. Common passwords are weak.
PasswordStrength passwordStrength(String password) {
  if (password.isEmpty) return PasswordStrength.none;
  if (isCommonPassword(password)) return PasswordStrength.weak;
  final met = kPasswordRules.where((r) => r.test(password)).length;
  final score = met + (password.length >= 12 ? 1 : 0);
  if (score >= 5) return PasswordStrength.strong;
  if (met == kPasswordRules.length) return PasswordStrength.fair;
  return PasswordStrength.weak;
}
