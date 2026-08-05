import 'package:flutter/material.dart';

import '../categories/categories_screen.dart';
import '../rooms/rooms_screen.dart';

/// Gabungan Kategori & Ruangan dalam satu tab (submenu via TabBar).
class MasterScreen extends StatelessWidget {
  const MasterScreen({super.key});

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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor:
                  Theme.of(context).colorScheme.onSurfaceVariant,
              tabs: const [
                Tab(text: 'Kategori'),
                Tab(text: 'Ruangan'),
              ],
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [
                CategoriesScreen(),
                RoomsScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
