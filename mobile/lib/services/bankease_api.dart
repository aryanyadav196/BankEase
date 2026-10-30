import 'api_client.dart';

class BankEaseApi {
  const BankEaseApi(this._client);
  final ApiClient _client;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) =>
      _client.post('/auth/login', body: {'email': email, 'password': password});

  Future<Map<String, dynamic>> registerCustomer({
    required String fullName,
    required String email,
    required String phone,
    required String address,
    required String password,
  }) => _client.post(
    '/auth/register',
    body: {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'address': address,
      'password': password,
    },
  );

  Future<Map<String, dynamic>> registerStaff({
    required String role,
    required String email,
    required String password,
  }) => _client.post(
    '/auth/register/${role.toLowerCase()}',
    body: {'email': email, 'password': password},
  );

  Future<Map<String, dynamic>> getMyProfile({required String token}) async =>
      _asMap(await _client.get('/customers/me', token: token));

  Future<List<Map<String, dynamic>>> getMyAccounts({
    required int customerId,
    required String token,
  }) async => _asList(
    await _client.get('/accounts/customer/$customerId', token: token),
  );

  Future<List<Map<String, dynamic>>> getMyTransactions({
    required String token,
  }) async => _asList(await _client.get('/transactions/my', token: token));

  Future<List<Map<String, dynamic>>> getMyServiceRequests({
    required int customerId,
    required String token,
  }) async => _asList(
    await _client.get('/service-requests/customer/$customerId', token: token),
  );

  Future<Map<String, dynamic>> createServiceRequest({
    required int customerId,
    required String type,
    required String description,
    required String token,
  }) async => _asMap(
    await _client.post(
      '/service-requests?customerId=$customerId',
      token: token,
      body: {'type': type, 'description': description},
    ),
  );

  Future<List<Map<String, dynamic>>> getEmployeeCustomers({
    required String token,
  }) async => _asList(await _client.get('/employee/customers', token: token));

  Future<Map<String, dynamic>> createAccount({
    required int customerId,
    required String accountType,
    required String token,
  }) async => _asMap(
    await _client.post(
      '/accounts?customerId=$customerId',
      token: token,
      body: {'accountType': accountType},
    ),
  );

  Future<List<Map<String, dynamic>>> getAllServiceRequests({
    required String token,
  }) async => _asList(await _client.get('/service-requests', token: token));

  Future<Map<String, dynamic>> startServiceRequest({
    required int requestId,
    required String token,
  }) async => _asMap(
    await _client.patch('/service-requests/$requestId/start', token: token),
  );

  Future<Map<String, dynamic>> resolveServiceRequest({
    required int requestId,
    required String token,
  }) async => _asMap(
    await _client.patch('/service-requests/$requestId/resolve', token: token),
  );

  Future<Map<String, dynamic>> rejectServiceRequest({
    required int requestId,
    required String token,
  }) async => _asMap(
    await _client.patch('/service-requests/$requestId/reject', token: token),
  );

  Future<Map<String, dynamic>> getAdminOverview({
    required String token,
  }) async => _asMap(await _client.get('/admin/overview', token: token));

  Future<List<Map<String, dynamic>>> getAdminAccounts({
    required String token,
  }) async => _asList(await _client.get('/admin/accounts', token: token));

  Future<List<Map<String, dynamic>>> getAdminTransactions({
    required String token,
  }) async => _asList(await _client.get('/admin/transactions', token: token));

  Future<List<Map<String, dynamic>>> getAutomationRules({
    required String token,
  }) async =>
      _asList(await _client.get('/admin/automation-rules', token: token));

  Future<List<Map<String, dynamic>>> getAuditLogs({
    required String token,
  }) async => _asList(await _client.get('/admin/audit-logs', token: token));

  Future<List<Map<String, dynamic>>> getPendingUsers({
    required String token,
  }) async => _asList(await _client.get('/admin/pending-users', token: token));

  Future<Map<String, dynamic>> approvePendingUser({
    required int userId,
    required String token,
  }) async => _asMap(
    await _client.patch('/admin/pending-users/$userId/approve', token: token),
  );

  Future<Map<String, dynamic>> removePendingUser({
    required int userId,
    required String token,
  }) async => _asMap(
    await _client.delete('/admin/pending-users/$userId', token: token),
  );

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    throw const ApiException('The server returned an unexpected object.');
  }

  List<Map<String, dynamic>> _asList(dynamic value) {
    if (value is List) return value.whereType<Map<String, dynamic>>().toList();
    throw const ApiException('The server returned an unexpected list.');
  }
}
