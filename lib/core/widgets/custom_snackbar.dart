import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../theme/app_theme.dart';

enum AppSnackType { info, success, warning, error }

/// Snackbar custom design system: pill/floating, ikon Phosphor, warna semantik.
void showAppSnackBar(
  BuildContext context,
  String message, {
  AppSnackType type = AppSnackType.info,
  Duration duration = const Duration(seconds: 3),
}) {
  final theme = Theme.of(context);
  final isLight = theme.brightness == Brightness.light;

  final IconData icon;
  final Color bg;
  final Color fg;
  switch (type) {
    case AppSnackType.success:
      icon = PhosphorIcons.checkCircle;
      bg = context.success;
      fg = isLight ? Colors.white : const Color(0xFF101218);
    case AppSnackType.warning:
      icon = PhosphorIcons.warningCircle;
      bg = context.warning;
      fg = isLight ? Colors.white : const Color(0xFF101218);
    case AppSnackType.error:
      icon = PhosphorIcons.xCircle;
      bg = context.danger;
      fg = isLight ? Colors.white : const Color(0xFF101218);
    case AppSnackType.info:
      icon = PhosphorIcons.info;
      bg = theme.colorScheme.inverseSurface;
      fg = theme.colorScheme.onInverseSurface;
  }

  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: duration,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            children: [
              Icon(icon, color: fg, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: fg,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
}
