import 'package:flutter_test/flutter_test.dart';

import 'package:mindpath_ai/services/validators.dart';

void main() {
  group('validateName', () {
    test('accepts normal names', () {
      for (final name in [
        'Ali',
        'Samama Zubair',
        "Mary-Jane O'Neil",
        '  Abdul Momin  ',
        'Zoë Ångström',
      ]) {
        expect(validateName(name), isNull, reason: name);
      }
    });

    test('rejects empty, short and long names', () {
      expect(validateName(null), isNotNull);
      expect(validateName('   '), isNotNull);
      expect(validateName('Al'), isNotNull);
      expect(validateName(' Al '), isNotNull); // trimmed before counting
      expect(validateName('a' * 51), isNotNull);
      expect(validateName('a' * 50), isNull);
    });

    test('rejects digits and symbols', () {
      for (final name in ['Ali2', 'Ali_Khan', 'Ali@Khan', '-Ali', 'Ali!']) {
        expect(validateName(name), isNotNull, reason: name);
      }
    });
  });

  test('normalizeName trims and collapses inner spaces', () {
    expect(normalizeName('  Ali    Khan  '), 'Ali Khan');
    expect(normalizeName('Ali\tKhan'), 'Ali Khan');
  });

  test('password edges: spaces at either end, and the length cap', () {
    expect(
      validatePassword(' Blue!River9'),
      'Password cannot start or end with a space',
    );
    expect(
      validatePassword('Blue!River9 '),
      'Password cannot start or end with a space',
    );
    expect(validatePassword('Blue! River9'), isNull); // inner space is fine
    expect(validatePassword('Aa1!' * 32), isNull); // 128 characters
    expect(validatePassword('Aa1!' * 32 + 'x'), isNotNull);
  });

  group('validateEmail', () {
    test('accepts valid emails, trimmed and case-insensitive', () {
      for (final email in [
        'user@example.com',
        '  User.Name+tag@Example.CO.uk ',
        'a_b-c@sub.domain.pk',
      ]) {
        expect(validateEmail(email), isNull, reason: email);
      }
    });

    test('normalizeEmail trims and lowercases', () {
      expect(normalizeEmail('  Foo@Bar.COM '), 'foo@bar.com');
    });

    test('rejects malformed emails', () {
      for (final email in [
        '',
        'plainaddress',
        'user@',
        '@example.com',
        'user@example',
        'user@@example.com',
        'user@exa mple.com',
        'us er@example.com',
        'user@-example.com',
        'user@example..com',
        '.user@example.com',
        'user.@example.com',
        'user@example.c',
      ]) {
        expect(validateEmail(email), isNotNull, reason: email);
      }
    });

    test('rejects emails over 254 chars', () {
      // Every part is valid on its own; only the total length is too long.
      final long = '${'a' * 60}@${'${'b' * 60}.' * 4}com';
      expect(long.length, greaterThan(254));
      expect(validateEmail(long), isNotNull);
    });
  });

  group('validateEmail on Register (checkTypos)', () {
    test('rejects the three malformed examples', () {
      for (final email in ['abc@gmial.com', 'abc@gmail', 'notanemail']) {
        expect(
          validateEmail(email, checkTypos: true),
          isNotNull,
          reason: email,
        );
      }
    });

    test('suggests the intended provider for a misspelt domain', () {
      expect(
        validateEmail('abc@gmial.com', checkTypos: true),
        'Please check the spelling. Did you mean abc@gmail.com?',
      );
      expect(
        validateEmail(' Sara@Hotmial.com ', checkTypos: true),
        'Please check the spelling. Did you mean sara@hotmail.com?',
      );
    });

    test('uses one plain message for bad formats', () {
      for (final email in ['abc@gmail', 'notanemail', 'a@b.c', '@x.com']) {
        expect(validateEmail(email), kInvalidEmailMessage, reason: email);
      }
    });

    test('Login does not check typos, so any existing account signs in', () {
      expect(validateEmail('abc@gmial.com'), isNull);
    });

    test('accepts real providers and other domains', () {
      for (final email in ['abc@gmail.com', 'x@szabist.edu.pk', 'y@gmx.com']) {
        expect(validateEmail(email, checkTypos: true), isNull, reason: email);
      }
    });
  });

  group('validatePassword', () {
    test('accepts a strong password', () {
      expect(validatePassword('Calm#Path24'), isNull);
      expect(
        validatePassword('Blue!River9', name: 'Ali Khan', email: 'ali@x.com'),
        isNull,
      );
    });

    test('enforces each character rule', () {
      expect(validatePassword(''), isNotNull);
      expect(validatePassword('Ab1!'), isNotNull); // too short
      expect(validatePassword('calm#path24'), isNotNull); // no upper
      expect(validatePassword('CALM#PATH24'), isNotNull); // no lower
      expect(validatePassword('Calm#Pathxx'), isNotNull); // no digit
      expect(validatePassword('CalmPath24'), isNotNull); // no special
    });

    test('rejects common passwords even with symbols added', () {
      expect(kCommonPasswords, hasLength(20));
      expect(validatePassword('Password1!'), 'This password is too common');
      expect(validatePassword('Passw0rd!'), 'This password is too common');
      expect(validatePassword('Qwerty123!'), 'This password is too common');
    });

    test('rejects passwords containing the name', () {
      const name = 'Samama Zubair';
      expect(validatePassword('Samama#2024', name: name), isNotNull);
      expect(validatePassword('x!ZUBAIR9y', name: name), isNotNull);
      expect(validatePassword('Calm#Path24', name: name), isNull);
    });

    test('rejects passwords containing the email local part', () {
      const email = 'waasay@example.com';
      expect(validatePassword('Waasay!123', email: email), isNotNull);
      expect(validatePassword('Calm#Path24', email: email), isNull);
    });
  });

  group('validateConfirmPassword', () {
    test('must match exactly', () {
      expect(validateConfirmPassword('Calm#Path24', 'Calm#Path24'), isNull);
      expect(validateConfirmPassword('calm#path24', 'Calm#Path24'), isNotNull);
      expect(validateConfirmPassword('Calm#Path24 ', 'Calm#Path24'), isNotNull);
      expect(validateConfirmPassword('', 'Calm#Path24'), isNotNull);
      expect(validateConfirmPassword(null, 'Calm#Path24'), isNotNull);
    });
  });

  group('passwordStrength', () {
    test('grades passwords', () {
      expect(passwordStrength(''), PasswordStrength.none);
      expect(passwordStrength('abc'), PasswordStrength.weak);
      expect(passwordStrength('Password1!'), PasswordStrength.weak);
      expect(passwordStrength('Calm#Path24'), PasswordStrength.fair);
      expect(passwordStrength('Calm#Path2024!'), PasswordStrength.strong);
    });

    test('checklist rules tick individually', () {
      final met = kPasswordRules.map((r) => r.test('abcdefgH')).toList();
      expect(met, [true, true, false, false]);
    });
  });
}
