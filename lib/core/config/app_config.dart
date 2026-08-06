/// Konfigurasi aplikasi yang disinkronkan dari server.
class AppConfig {
  AppConfig._();

  /// Ambang stok menipis (dari pengaturan server `low_stock_threshold`).
  /// Diperbarui saat aplikasi mengambil `/status`.
  static int lowStockThreshold = 5;
}
