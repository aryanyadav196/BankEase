import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/services/api_client.dart';

void main() {
  test('ApiException carries safe endpoint diagnostics without secrets', () {
    const error = ApiException(
      'Request failed.',
      statusCode: 403,
      endpoint: '/admin/overview',
      safeResponse: '{"message":"Forbidden"}',
    );

    expect(error.endpoint, '/admin/overview');
    expect(error.statusCode, 403);
    expect(error.safeResponse, isNot(contains('token')));
    expect(error.safeResponse, contains('Forbidden'));
  });
}
