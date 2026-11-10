/// Pure form validators. Each returns null when valid, else a short message.
library;

final RegExp _nameChars = RegExp(r"^[\p{L}][\p{L} '\-]*$", unicode: true);

final RegExp _email = RegExp(
  r"^[a-z0-9!#$%&'*+/=?^_`{|}~-]+(\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*"
  r'@([a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z]{2,63}$',
);

final RegExp _spaces = RegExp(r'\s+');

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

/// Longest accepted values. The fields stop accepting input at these
/// lengths, so pasted text cannot grow without bound.
const int kMaxNameLength = 50;
const int kMaxEmailLength = 254;
const int kMaxPasswordLength = 128;

/// Shown for any email that is not in name@example.com form.
const String kInvalidEmailMessage = 'Please enter a valid email address';

/// Misspellings of the big email providers, mapped to the intended domain.
/// Each is a well-formed address that would never receive mail, so a
/// regular expression alone lets it through.
const Map<String, String> kEmailDomainTypos = {
  'gmial.com': 'gmail.com',
  'gmal.com': 'gmail.com',
  'gmai.com': 'gmail.com',
  'gamil.com': 'gmail.com',
  'gnail.com': 'gmail.com',
  'gmaill.com': 'gmail.com',
  'gmali.com': 'gmail.com',
  'gmail.co': 'gmail.com',
  'gmail.con': 'gmail.com',
  'gmail.cm': 'gmail.com',
  'gmail.om': 'gmail.com',
  'hotmial.com': 'hotmail.com',
  'hotmal.com': 'hotmail.com',
  'hotmai.com': 'hotmail.com',
  'hotmail.co': 'hotmail.com',
  'hotmail.con': 'hotmail.com',
  'yahooo.com': 'yahoo.com',
  'yaho.com': 'yahoo.com',
  'yhaoo.com': 'yahoo.com',
  'yahoo.co': 'yahoo.com',
  'yahoo.con': 'yahoo.com',
  'outlok.com': 'outlook.com',
  'outllok.com': 'outlook.com',
  'outlook.co': 'outlook.com',
  'outlook.con': 'outlook.com',
  'iclod.com': 'icloud.com',
  'icloud.co': 'icloud.com',
};

/// Trims the ends and turns each run of spaces inside into one space.
String normalizeName(String value) => value.trim().replaceAll(_spaces, ' ');

String normalizeEmail(String value) => value.trim().toLowerCase();

String? validateName(String? value) {
  final name = normalizeName(value ?? '');
  if (name.isEmpty) return 'Please enter your full name';
  if (name.length < 3) return 'Name must be at least 3 letters';
  if (name.length > kMaxNameLength) {
    return 'Name must be $kMaxNameLength letters or fewer';
  }
  if (!_nameChars.hasMatch(name)) {
    return "Please use letters only (spaces, - and ' are fine)";
  }
  return null;
}

/// Checks the form local-part@domain.tld. With [checkTypos] it also
/// catches misspelt provider domains such as gmial.com; Register sets it,
/// Login does not, so an existing account can always sign in.
String? validateEmail(String? value, {bool checkTypos = false}) {
  final email = normalizeEmail(value ?? '');
  if (email.isEmpty) return 'Please enter your email';
  if (email.contains(_spaces)) return 'Email cannot contain spaces';
  if (email.length > kMaxEmailLength) return 'Email is too long';
  if (email.split('@').first.length > 64 || !_email.hasMatch(email)) {
    return kInvalidEmailMessage;
  }
  if (checkTypos) {
    final at = email.lastIndexOf('@');
    final fix = kEmailDomainTypos[email.substring(at + 1)];
    if (fix != null) {
      return 'Please check the spelling. Did you mean '
          '${email.substring(0, at)}@$fix?';
    }
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
    'A capital letter and a small letter',
    (p) => _upper.hasMatch(p) && _lower.hasMatch(p),
  ),
  PasswordRule('At least one number', (p) => _digit.hasMatch(p)),
  PasswordRule('At least one symbol, like ! or #', (p) => _special.hasMatch(p)),
];

bool isCommonPassword(String password) => kCommonPasswords.contains(
  password.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), ''),
);

/// [name] and [email] are optional; when given, the password may not contain
/// the name (or any 3+ letter part of it) or the email's local part.
String? validatePassword(String? value, {String name = '', String email = ''}) {
  final password = value ?? '';
  if (password.isEmpty) return 'Please enter a password';
  // A pasted password often carries an invisible space at either end,
  // which the user would then never type again at login.
  if (password.trim() != password) {
    return 'Password cannot start or end with a space';
  }
  if (password.length < 8) return 'Use at least 8 characters';
  if (password.length > kMaxPasswordLength) {
    return 'Use $kMaxPasswordLength characters or fewer';
  }
  if (!_upper.hasMatch(password)) return 'Add a capital letter (A-Z)';
  if (!_lower.hasMatch(password)) return 'Add a small letter (a-z)';
  if (!_digit.hasMatch(password)) return 'Add a number (0-9)';
  if (!_special.hasMatch(password)) return 'Add a symbol, like ! or #';
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
  if (value == null || value.isEmpty) return 'Please type your password again';
  if (value != password) return 'Passwords do not match';
  return null;
}

/// Login only checks presence; rules apply when the password is created.
String? validateLoginPassword(String? value) =>
    (value == null || value.isEmpty) ? 'Please enter your password' : null;

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
