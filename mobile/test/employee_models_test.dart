import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/models/employee_customer.dart';
import 'package:mobile/models/employee_service_request.dart';

void main() {
  test('employee DTO fields are parsed', () {
    final customer = EmployeeCustomer.fromJson({
      'id': 12,
      'fullName': 'Example Customer',
      'email': 'example@example.com',
      'phone': '0000000000',
      'address': 'Example address',
    });
    final request = EmployeeServiceRequest.fromJson({
      'id': 21,
      'type': 'GENERAL_QUERY',
      'status': 'IN_PROGRESS',
      'priority': 'MEDIUM',
      'description': 'Example request',
      'createdAt': '2026-01-01T10:00:00',
      'updatedAt': '2026-01-01T11:00:00',
      'customerId': 12,
      'customerName': 'Example Customer',
    });

    expect(customer.id, 12);
    expect(customer.email, 'example@example.com');
    expect(request.status, 'IN_PROGRESS');
    expect(request.customerName, 'Example Customer');
  });
}
