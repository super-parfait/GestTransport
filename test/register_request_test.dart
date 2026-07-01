import 'package:flutter_test/flutter_test.dart';

import 'package:sand_gravel_app/features/auth/data/models/register_request.dart';

void main() {
  test('register payload includes the required role', () {
    const request = RegisterRequest(
      name: 'Ahmed',
      phone: '+225 555 123 456',
      password: 'password123',
      role: 'DRIVER',
    );

    expect(request.toJson(), {
      'name': 'Ahmed',
      'phone': '+225 555 123 456',
      'password': 'password123',
      'role': 'DRIVER',
    });
  });

  test('register payload trims the explicit role', () {
    const request = RegisterRequest(
      name: 'Ahmed',
      phone: '+225 555 123 456',
      password: 'password123',
      role: ' MANAGER ',
    );

    expect(request.toJson(), {
      'name': 'Ahmed',
      'phone': '+225 555 123 456',
      'password': 'password123',
      'role': 'MANAGER',
    });
  });
}
