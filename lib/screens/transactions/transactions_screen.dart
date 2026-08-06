import 'package:flutter/material.dart';

import 'incoming_screen.dart';
import 'outgoing_screen.dart';

/// Gabungan barang masuk & barang keluar dalam satu tab (submenu via TabBar).
class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant,
              tabs: const [
                Tab(text: 'Masuk'),
                Tab(text: 'Keluar'),
              ],
            ),
          ),
          const Expanded(
            child: TabBarView(children: [IncomingScreen(), OutgoingScreen()]),
          ),
        ],
      ),
    );
  }
}
