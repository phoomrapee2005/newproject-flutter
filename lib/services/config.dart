/// การตั้งค่าแอปพลิเคชัน
class AppConfig {
  // API Configuration
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/api',
  );

  // Debug Mode
  static const bool isDebug = bool.fromEnvironment(
    'DEBUG_MODE',
    defaultValue: true,
  );

  // Shipping Fees
  static const double shippingFeeNormal = 50.0;
  static const double shippingFeeExpress = 100.0;

  // Bank Information
  static const String bankName = 'กสิกรไทย';
  static const String bankAccountNumber = '1234567890';
  static const String bankAccountName = 'Click & Clack';

  // App Information
  static const String appName = 'Click & Clack';
  static const String appSubtitle = 'Gaming Gear มือ 1 & มือ 2';

  // Product Categories
  static const List<String> categories = [
    'เมาส์',
    'คีย์บอร์ด',
    'หูฟัง',
    'แผ่นรองเมาส์',
    'อื่นๆ',
  ];

  // Order Status
  static const String statusPending = 'pending';
  static const String statusPaid = 'paid';
  static const String statusShipping = 'shipping';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';
}
