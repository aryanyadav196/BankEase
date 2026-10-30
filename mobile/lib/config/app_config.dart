class AppConfig {
  const AppConfig._();

  // Android emulators reach the host machine through 10.0.2.2.
  // Override this at run time for a physical device or another environment:
  // flutter run --dart-define=API_BASE_URL=http://192.168.1.20:8082/api
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8082/api',
  );
}
