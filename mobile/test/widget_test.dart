import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:mobile/config/app_config.dart';
import 'package:mobile/main.dart';
import 'package:mobile/models/auth_session.dart';
import 'package:mobile/services/api_client.dart';
import 'package:mobile/services/bankease_api.dart';
import 'package:mobile/state/session_controller.dart';

void main() {
  testWidgets('BankEase login shell renders', (tester) async {
    final session = SessionController(
      api: BankEaseApi(ApiClient(baseUrl: AppConfig.apiBaseUrl)),
    );

    await tester.pumpWidget(BankEaseApp(session: session));

    expect(find.text('BankEase'), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('Admin dashboard loads verified sections from API responses', (
    tester,
  ) async {
    final session =
        SessionController(
            api: BankEaseApi(
              ApiClient(
                baseUrl: 'http://test/api',
                client: _FakeAdminHttpClient(),
              ),
            ),
          )
          ..session = const AuthSession(
            token: 'test-token',
            email: 'admin@example.com',
            role: 'ADMIN',
          );

    await tester.pumpWidget(BankEaseApp(session: session));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('Audit'), findsOneWidget);
  });
}

class _FakeAdminHttpClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final path = request.url.path;
    dynamic response;
    if (path.endsWith('/admin/overview')) {
      response = {
        'totalUsers': 1,
        'totalCustomers': 1,
        'totalAccounts': 1,
        'totalTransactions': 1,
        'pendingServiceRequests': 0,
        'blockedAccounts': 0,
        'rejectedTransactions': 0,
        'totalAuditLogs': 1,
        'activeAutomationRules': 1,
      };
    } else if (path.endsWith('/admin/pending-users') ||
        path.endsWith('/admin/accounts') ||
        path.endsWith('/admin/transactions') ||
        path.endsWith('/admin/automation-rules') ||
        path.endsWith('/admin/audit-logs')) {
      response = <dynamic>[];
    } else {
      response = <String, dynamic>{};
    }
    return http.StreamedResponse(
      Stream.value(utf8.encode(jsonEncode(response))),
      200,
      request: request,
      headers: const {'content-type': 'application/json'},
    );
  }
}
