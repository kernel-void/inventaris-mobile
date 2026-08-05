import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'Inventaris Sekolah';

  /// Base URL API backend Laravel.
  ///
  /// - Android emulator memakai 10.0.2.2 agar bisa mengakses localhost host.
  /// - Windows/web/desktop memakai localhost langsung.
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8000/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000/api';
    return 'http://localhost:8000/api';
  }

  static const int perPage = 15;
}
