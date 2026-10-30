import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/models/auth_session.dart';

void main() {
  test('AuthSession parses and serializes the backend login response', () {
    const response = {
      'token': 'example-token',
      'email': 'customer@example.com',
      'role': 'CUSTOMER',
    };

    final session = AuthSession.fromJson(response);

    expect(session.token, 'example-token');
    expect(session.email, 'customer@example.com');
    expect(session.role, 'CUSTOMER');
    expect(session.toJson(), response);
  });
}
