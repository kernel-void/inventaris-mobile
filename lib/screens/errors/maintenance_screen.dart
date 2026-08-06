import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/custom_snackbar.dart';
import '../auth/login_screen.dart';
import '../home/dashboard_screen.dart';

/// Layar yang tampil saat server dalam mode pemeliharaan (HTTP 503).
class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key, this.onResolved});

  /// Dipanggil saat layar ditutup, agar penanganan 503 bisa aktif lagi.
  final VoidCallback? onResolved;

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  bool _checking = false;

  @override
  void dispose() {
    widget.onResolved?.call();
    super.dispose();
  }

  Future<void> _retry() async {
    setState(() => _checking = true);
    try {
      await ApiClient.instance.request('/status');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _checking = false);
      if (e.statusCode == 503) {
        // Masih dalam maintenance: tetap di layar maintenance.
        return;
      }
      showAppSnackBar(context, e.message, type: AppSnackType.error);
      return;
    }
    // Maintenance sudah selesai.
    try {
      await ApiClient.instance.request('/user');
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
        (route) => false,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.statusCode == 401) {
        // Sesi tidak valid: kembali ke halaman login.
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
        return;
      }
      setState(() => _checking = false);
      showAppSnackBar(context, e.message, type: AppSnackType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: context.warning.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Icon(
                      PhosphorIcons.wrench,
                      size: 32,
                      color: context.warning,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Sistem Sedang Maintenance',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Layanan sedang dalam mode pemeliharaan. '
                  'Silahkan kembali dalam beberapa saat lagi.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: _checking ? null : _retry,
                  child: _checking
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
