import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/outgoing_item.dart';
import '../../providers/auth_provider.dart';
import '../../providers/item_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/error_view.dart';
import '../../widgets/icon_badge.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/transaction_filter_bar.dart';
import 'transaction_form_screen.dart';

class OutgoingScreen extends StatefulWidget {
  const OutgoingScreen({super.key});

  @override
  State<OutgoingScreen> createState() => _OutgoingScreenState();
}

class _OutgoingScreenState extends State<OutgoingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadOutgoing();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final auth = context.watch<AuthProvider>();
    final itemProvider = context.watch<ItemProvider>();
    final isEmptyByFilter = provider.outgoing.isEmpty &&
        !provider.outgoingFilter.isEmpty &&
        !provider.loading;

    return Scaffold(
      body: Column(
        children: [
          TransactionFilterBar(
            filter: provider.outgoingFilter,
            hint: 'Cari barang keluar...',
            loadItems: itemProvider.fetchAllItems,
            onChanged: (f) => provider.setOutgoingFilter(f),
          ),
          Expanded(
            child: provider.loading && provider.outgoing.isEmpty
                ? const LoadingWidget(text: 'Memuat barang keluar...')
                : provider.error != null && provider.outgoing.isEmpty
                    ? ErrorView(
                        message: provider.error!,
                        onRetry: () => provider.loadOutgoing(),
                      )
                    : provider.outgoing.isEmpty
                        ? Center(
                            child: Text(
                              isEmptyByFilter
                                  ? 'Tidak ditemukan dengan filter ini'
                                  : 'Belum ada barang keluar',
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () => provider.loadOutgoing(),
                            child: ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                              itemCount: provider.outgoing.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final record = provider.outgoing[index];
                                return _OutgoingTile(record: record);
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: auth.can('outgoing-items.create')
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const TransactionFormScreen(
                      type: TransactionType.outgoing,
                    ),
                  ),
                );
                if (context.mounted) {
                  context.read<TransactionProvider>().loadOutgoing();
                  context.read<ItemProvider>().loadItems(refresh: true);
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Barang Keluar'),
            )
          : null,
    );
  }
}

class _OutgoingTile extends StatelessWidget {
  const _OutgoingTile({required this.record});

  final OutgoingItem record;

  @override
  Widget build(BuildContext context) {
    final destination =
        record.destination != null && record.destination!.isNotEmpty
            ? record.destination
            : null;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const IconBadge(
              icon: Icons.north_east,
              color: AppTheme.danger,
              size: 44,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(record.item?.name ?? 'Barang',
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(
                    [
                      record.transactionNumber,
                      record.date,
                      if (destination != null) '→ $destination',
                      record.createdBy,
                    ].whereType<String>().join(' · '),
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.danger.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '-${record.quantity}',
                style: const TextStyle(
                  color: AppTheme.danger,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
