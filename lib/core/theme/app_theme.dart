import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// =====================================================================
///  DESIGN SYSTEM — Inventaris Sekolah
/// =====================================================================
///  Aturan (wajib ditaati semua screen):
///  - Modern, minimalist, flat. Bukan gradient / neumorphism / neon.
///  - HANYA satu warna brand (biru tua) sebagai aksen dominan.
///  - Merah/kuning/hijau HANYA untuk status semantik (error/warning/success).
///  - Semua screen memakai Theme.of(context) — JANGAN hardcode warna.
///  - Font Plus Jakarta Sans, max 2 weight: 400 (regular) & 500 (medium).
///    700 hanya untuk angka besar di dashboard.
///  - Radius konsisten: card 16px, control (button/input) 10px, chip = pill.
///  - Card tanpa shadow tebal, gunakan border tipis.
/// =====================================================================

class AppTheme {
  AppTheme._();

  /// Satu-satunya warna brand di seluruh aplikasi (biru tua).
  static const Color seedColor = Color(0xFF1D4ED8);

  /// Radius konsisten.
  static const double radiusCard = 16;
  static const double radiusControl = 10;

  /// Spasi konsisten.
  static const double pagePadding = 20;
  static const double cardPadding = 16;
  static const double sectionGap = 20;
  static const double gapSm = 12;
  static const double gapXs = 8;

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final bool isLight = brightness == Brightness.light;

    // ── Warna dasar netral ──────────────────────────────────────────────
    final Color bg = isLight ? const Color(0xFFF7F8FA) : const Color(0xFF101218);
    final Color surface = isLight ? Colors.white : const Color(0xFF171A21);
    final Color border = isLight ? const Color(0xFFE7E9EF) : const Color(0xFF262A33);
    final Color textPrimary = isLight ? const Color(0xFF1A1D23) : const Color(0xFFECEDF1);
    final Color textSecondary = isLight ? const Color(0xFF6B7280) : const Color(0xFF9AA0AA);

    final scheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    ).copyWith(
      surface: surface,
      onSurface: textPrimary,
      onSurfaceVariant: textSecondary,
      surfaceContainerLowest: bg,
      surfaceContainerLow: surface,
      surfaceContainer: isLight ? const Color(0xFFF2F3F6) : const Color(0xFF1C1F27),
    );

    // ── Tipografi: Plus Jakarta Sans, weight 400 & 500 ──────────────────
    final base = GoogleFonts.plusJakartaSansTextTheme(
      ThemeData(brightness: brightness).textTheme,
    );
    final textTheme = base.copyWith(
      // Angka besar dashboard (satu-satunya yang boleh bold 700)
      displaySmall: base.displaySmall?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -0.6,
      ),
      // Judul screen 18-20px
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: textPrimary,
        letterSpacing: -0.3,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: textPrimary,
        letterSpacing: -0.2,
      ),
      // Judul card 14-15px
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      // Body 13-14px
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        height: 1.45,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        height: 1.45,
      ),
      // Caption/label 11-12px
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        height: 1.4,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textSecondary,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: textSecondary,
      ),
    );

    const controlShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(radiusControl)),
    );
    final cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(radiusCard)),
      side: BorderSide(color: border, width: 1),
    );
    final filledBg = isLight ? const Color(0xFFF4F5F7) : const Color(0xFF1A1D23);

    return ThemeData(
      brightness: brightness,
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: bg,
      textTheme: textTheme,

      // ── Card: flat, border tipis, tanpa shadow ─────────────────────────
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: cardShape,
      ),

      // ── App bar ────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
      ),

      // ── Input ──────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: filledBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        // Label/placeholder selalu muted (abu) di semua state — normal, focus,
        // maupun error. Hanya border & pesan error yang berubah merah.
        labelStyle: textTheme.bodyMedium?.copyWith(color: textSecondary),
        floatingLabelStyle: textTheme.bodyMedium?.copyWith(
          color: textSecondary,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: textSecondary),
        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusControl),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusControl),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusControl),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusControl),
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusControl),
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
      ),

      // ── Tombol ─────────────────────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: scheme.primary.withValues(alpha: 0.4),
          disabledForegroundColor: scheme.onPrimary.withValues(alpha: 0.8),
          minimumSize: const Size(64, 50),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          textStyle: textTheme.labelLarge?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          shape: controlShape,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          minimumSize: const Size(64, 50),
          textStyle: textTheme.labelLarge?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          shape: controlShape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: const Size(64, 50),
          side: BorderSide(color: border),
          textStyle: textTheme.labelLarge?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          shape: controlShape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: textTheme.labelLarge?.copyWith(fontSize: 13),
        ),
      ),

      // ── Lainnya ────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.primary.withValues(alpha: 0.15),
        circularTrackColor: scheme.primary.withValues(alpha: 0.15),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: scheme.primary,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isLight ? const Color(0xFF111827) : const Color(0xFF23262E),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w400,
        ),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

/// Warna semantik — akses lewat konteks, bukan hardcode di widget.
extension AppColorsX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => theme.colorScheme;

  /// Aksen utama = warna brand.
  Color get primary => colors.primary;

  /// Hijau = sukses.
  Color get success => theme.brightness == Brightness.light
      ? const Color(0xFF16A34A)
      : const Color(0xFF4ADE80);

  /// Kuning = warning.
  Color get warning => theme.brightness == Brightness.light
      ? const Color(0xFFD97706)
      : const Color(0xFFFBBF24);

  /// Merah = error/kritis.
  Color get danger => colors.error;
}
