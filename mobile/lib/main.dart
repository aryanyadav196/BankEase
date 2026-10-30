import 'package:flutter/material.dart';

import 'config/app_config.dart';
import 'screens/auth/login_screen.dart';
import 'screens/customer/customer_dashboard_screen.dart';
import 'screens/employee/employee_dashboard_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/home/role_home_screen.dart';
import 'services/api_client.dart';
import 'services/bankease_api.dart';
import 'state/session_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final session = SessionController(
    api: BankEaseApi(ApiClient(baseUrl: AppConfig.apiBaseUrl)),
  );
  await session.restore();

  runApp(BankEaseApp(session: session));
}

class BankEaseApp extends StatelessWidget {
  const BankEaseApp({required this.session, super.key});

  final SessionController session;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: session,
      builder: (context, _) {
        return MaterialApp(
          title: 'BankEase',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xff1769e0),
              brightness: Brightness.light,
            ),
            inputDecorationTheme: const InputDecorationTheme(
              border: OutlineInputBorder(),
              filled: true,
            ),
          ),
          home: session.isAuthenticated
              ? session.session?.role == 'CUSTOMER'
                    ? CustomerDashboardScreen(session: session)
                    : session.session?.role == 'EMPLOYEE'
                    ? EmployeeDashboardScreen(session: session)
                    : session.session?.role == 'ADMIN'
                    ? AdminDashboardScreen(session: session)
                    : RoleHomeScreen(session: session)
              : LoginScreen(session: session),
        );
      },
    );
  }
}
