import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../models/incoming_item.dart';
import '../../providers/auth_provider.dart';
import '../../providers/item_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/error_view.dart';
import '../../widgets/icon_badge.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/transaction_filter_bar.dart';
import 'transaction_form_screen.dart';

class IncomingScreen extends StatefulWidget {
  const IncomingScreen({super.key});

  @override
  State<IncomingScreen> createState() => _IncomingScreenState();
}

class _IncomingScreenState extends State<IncomingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadIncoming();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final auth = context.watch<AuthProvider>();
    final itemProvider = context.watch<ItemProvider>();
    final isEmptyByFilter =
        provider.incoming.isEmpty &&
        !provider.incomingFilter.isEmpty &&
        !provider.loading;

    return Scaffold(
      body: Column(
        children: [
          TransactionFilterBar(
            filter: provider.incomingFilter,
            hint: 'Cari barang masuk...',
            loadItems: itemProvider.fetchAllItems,
            onChanged: (f) => provider.setIncomingFilter(f),
          ),
          Expanded(
            child: provider.loading && provider.incoming.isEmpty
                ? const LoadingWidget(text: 'Memuat barang masuk...')
                : provider.error != null && provider.incoming.isEmpty
                ? ErrorView(
                    message: provider.error!,
                    onRetry: () => provider.loadIncoming(),
                  )
                : provider.incoming.isEmpty
                ? Center(
                    child: Text(
                      isEmptyByFilter
                          ? 'Tidak ditemukan dengan filter ini'
                          : 'Belum ada barang masuk',
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => provider.loadIncoming(),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                      itemCount: provider.incoming.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final record = provider.incoming[index];
                        return _IncomingTile(record: record)
                            .animate(delay: (index * 30).ms)
                            .fadeIn(duration: 300.ms)
                            .moveY(
                              begin: 8,
                              duration: 300.ms,
                              curve: Curves.easeOut,
                            );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: auth.can('incoming-items.create')
          ? FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const TransactionFormScreen(
                      type: TransactionType.incoming,
                    ),
                  ),
                );
                if (context.mounted) {
                  context.read<TransactionProvider>().loadIncoming();
                  context.read<ItemProvider>().loadItems(refresh: true);
                }
              },
              icon: const Icon(PhosphorIcons.plus),
              label: const Text('Barang Masuk'),
            )
          : null,
    );
  }
}

class _IncomingTile extends StatelessWidget {
  const _IncomingTile({required this.record});

  final IncomingItem record;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            IconBadge(
              icon: PhosphorIcons.arrowDownLeft,
              color: context.success,
              size: 44,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.item?.name ?? 'Barang',
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [
                      record.transactionNumber,
                      record.date,
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
                color: context.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '+${record.quantity}',
                style: TextStyle(
                  color: context.success,
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
