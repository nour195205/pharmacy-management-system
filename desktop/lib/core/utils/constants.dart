class AppConstants {
  // API URL settings
  static const String baseApiUrl = 'http://127.0.0.1:8000/api/v1';
  static const int apiConnectTimeoutMs = 15000;
  static const int apiReceiveTimeoutMs = 15000;

  // Local Storage Settings
  static const String dbName = 'pharmacy_offline_first.db';
  static const int dbVersion = 1;

  // Synchronization configurations
  static const Duration syncInterval = Duration(seconds: 45);
  static const int syncMaxRetries = 3;
}
