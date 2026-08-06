import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'core/api/api_client.dart';
import 'core/api/api_exception.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/item_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/user_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/errors/maintenance_screen.dart';
import 'screens/home/dashboard_screen.dart';
import 'widgets/loading_widget.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

bool _maintenanceScreenShowing = false;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ApiClient.instance.onMaintenance = () {
    if (_maintenanceScreenShowing) return;
    _maintenanceScreenShowing = true;
    appNavigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => MaintenanceScreen(
          onResolved: () => _maintenanceScreenShowing = false,
        ),
      ),
      (route) => false,
    );
  };
  runApp(const InventarisApp());
}

class InventarisApp extends StatelessWidget {
  const InventarisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            onSessionExpired: () {
              appNavigatorKey.currentState?.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ),
        ChangeNotifierProvider(create: (_) => ItemProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'Inventaris Sekolah',
        debugShowCheckedModeBanner: false,
        navigatorKey: appNavigatorKey,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: const AppBootstrap(),
      ),
    );
  }
}

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _boot();
    });
  }

  Future<void> _boot() async {
    final auth = context.read<AuthProvider>();
    try {
      await ApiClient.instance.request('/status');
    } on ApiException catch (e) {
      if (e.statusCode == 503) {
        // Handler onMaintenance sudah menampilkan layar maintenance.
        return;
      }
    }
    final loggedIn = await auth.restoreSession();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            loggedIn ? const DashboardScreen() : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: LoadingWidget(text: 'Memuat sesi...'));
  }
}
