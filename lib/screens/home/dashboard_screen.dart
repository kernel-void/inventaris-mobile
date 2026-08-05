import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/dashboard.dart';
import '../../providers/auth_provider.dart';
import '../../providers/item_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/stat_card.dart';
import '../items/items_screen.dart';
import '../master/master_screen.dart';
import '../profile/profile_screen.dart';
import '../reports/report_screen.dart';
import '../transactions/transactions_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ItemProvider>();
      provider.loadReferences();
      _loadDashboard(provider);
    });
  }

  Future<void> _loadDashboard(ItemProvider provider) async {
    try {
      await provider.loadDashboard();
      if (mounted && _error != null) setState(() => _error = null);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<ItemProvider>();
    final isAdmin = auth.user?.roles.contains('admin') ?? false;

    final screens = [
      _DashboardTab(
        provider: provider,
        error: _error,
        userName: auth.user?.name,
        canReports: auth.can('reports.view'),
      ),
      const ItemsScreen(),
      if (isAdmin) const MasterScreen(),
      const TransactionsScreen(),
      const ProfileScreen(),
    ];

    final destinations = [
      const NavigationDestination(
        icon: Icon(Icons.grid_view_outlined),
        selectedIcon: Icon(Icons.grid_view_rounded),
        label: 'Dashboard',
      ),
      const NavigationDestination(
        icon: Icon(Icons.inventory_2_outlined),
        selectedIcon: Icon(Icons.inventory_2),
        label: 'Barang',
      ),
      if (isAdmin)
        const NavigationDestination(
          icon: Icon(Icons.sell_outlined),
          selectedIcon: Icon(Icons.sell),
          label: 'Master',
        ),
      const NavigationDestination(
        icon: Icon(Icons.swap_vert),
        selectedIcon: Icon(Icons.swap_vert_circle),
        label: 'Transaksi',
      ),
      const NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: 'Profil',
      ),
    ];

    final titles = [
      'Dashboard',
      'Barang',
      if (isAdmin) 'Master',
      'Transaksi',
      'Profil',
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(titles[_selectedIndex]),
      ),
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: destinations,
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab({
    required this.provider,
    this.error,
    this.userName,
    this.canReports = false,
  });

  final ItemProvider provider;
  final String? error;
  final String? userName;
  final bool canReports;

  static const _days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
  static const _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  Future<void> _reload() async {
    try {
      await provider.loadDashboard();
    } catch (_) {}
  }

  String _dateLabel() {
    final now = DateTime.now();
    return '${_days[now.weekday - 1]}, ${now.day} ${_months[now.month - 1]} ${now.year}';
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    return hour < 11
        ? 'Selamat pagi'
        : hour < 15
            ? 'Selamat siang'
            : hour < 19
                ? 'Selamat sore'
                : 'Selamat malam';
  }

  @override
  Widget build(BuildContext context) {
    if (provider.loading && provider.dashboard == null) {
      return const LoadingWidget(text: 'Memuat dashboard...');
    }
    if (error != null) {
      return ErrorView(
        message: error!,
        onRetry: () => provider.loadDashboard(),
      );
    }

    final dashboard = provider.dashboard;
    if (dashboard == null) {
      return const LoadingWidget();
    }

    return RefreshIndicator(
      onRefresh: _reload,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _buildHero(context, dashboard),
          const SizedBox(height: 20),
          _buildStats(context, dashboard),
          const SizedBox(height: 20),
          if (canReports) ...[
            _buildReportCard(context),
            const SizedBox(height: 20),
          ],
          _buildLowStockSection(context, dashboard),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context, DashboardData dashboard) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary, Color(0xFF7C3AED)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.30),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -18,
            right: -18,
            child: Icon(
              Icons.inventory_2_rounded,
              size: 120,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _dateLabel(),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${_greeting()},',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                userName ?? 'Pengguna',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${dashboard.stats.totalItems} barang terdaftar',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStats(BuildContext context, DashboardData dashboard) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.45,
      children: [
        StatCard(
          icon: Icons.inventory_2_outlined,
          label: 'Total Barang',
          value: '${dashboard.stats.totalItems}',
          color: AppTheme.primary,
        ),
        StatCard(
          icon: Icons.sell_outlined,
          label: 'Kategori',
          value: '${dashboard.stats.totalCategories}',
          color: AppTheme.warning,
        ),
        StatCard(
          icon: Icons.meeting_room_outlined,
          label: 'Ruangan',
          value: '${dashboard.stats.totalRooms}',
          color: AppTheme.success,
        ),
        StatCard(
          icon: Icons.compare_arrows,
          label: 'Masuk / Keluar',
          value:
              '${dashboard.stats.totalIncoming} / ${dashboard.stats.totalOutgoing}',
          color: const Color(0xFF8B5CF6),
        ),
      ],
    );
  }

  Widget _buildReportCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ReportScreen()),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.description_outlined,
                  color: AppTheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Laporan',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 2),
                  Text('Inventaris, barang masuk & keluar',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildLowStockSection(BuildContext context, DashboardData dashboard) {
    final items = dashboard.lowStockItems;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.warning_amber_rounded,
                    size: 20, color: AppTheme.warning),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Stok Menipis',
                        style: Theme.of(context).textTheme.titleMedium),
                    Text('Sisa stok 5 atau kurang',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              if (items.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.warning,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${items.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (items.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppTheme.success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Column(
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 28, color: AppTheme.success),
                  SizedBox(height: 6),
                  Text('Semua stok aman',
                      style: TextStyle(color: AppTheme.success)),
                ],
              ),
            )
          else
            ...items.map((item) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name,
                                style: Theme.of(context).textTheme.titleSmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            Text(item.code,
                                style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.warning,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${item.stock} ${item.unit ?? ''}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }
}
