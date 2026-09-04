import 'package:flutter_test/flutter_test.dart';
import 'package:laon/core/utils/validators.dart';

void main() {
  group('Validators tests', () {
    test('validateName accepts only letters and spaces', () {
      expect(Validators.validateName('John Doe'), isNull);
      expect(Validators.validateName('Rahul Patil'), isNull);
      expect(Validators.validateName('John123'), contains('must contain only letters'));
      expect(Validators.validateName('Ramesh @123'), contains('must contain only letters'));
      expect(Validators.validateName(''), contains('is required'));
    });

    test('validateMobile accepts valid 10-digit mobile numbers', () {
      expect(Validators.validateMobile('9850123456'), isNull);
      expect(Validators.validateMobile('+919850123456'), isNull);
      expect(Validators.validateMobile('98501'), contains('valid 10-digit mobile number'));
      expect(Validators.validateMobile('9850123456789'), contains('valid 10-digit mobile number'));
      expect(Validators.validateMobile('98501abcde'), contains('valid 10-digit mobile number'));
      expect(Validators.validateMobile(''), contains('is required'));
    });

    test('validateEmail validates proper email structure', () {
      expect(Validators.validateEmail('test@example.com'), isNull);
      expect(Validators.validateEmail('ramesh.farmer@gmail.com'), isNull);
      expect(Validators.validateEmail('invalid-email'), contains('valid email address'));
      expect(Validators.validateEmail(''), contains('is required'));
    });

    test('validatePassword validates minimum 6 characters', () {
      expect(Validators.validatePassword('123456'), isNull);
      expect(Validators.validatePassword('password123'), isNull);
      expect(Validators.validatePassword('12345'), contains('at least 6 characters'));
      expect(Validators.validatePassword(''), contains('is required'));
    });
  });
}
