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
    if (kIsWeb) return 'https://inventaris.mhfann.my.id/api';
    if (Platform.isAndroid) return 'https://inventaris.mhfann.my.id/api';
    return 'https://inventaris.mhfann.my.id/api';
  }

  static const int perPage = 15;
}
