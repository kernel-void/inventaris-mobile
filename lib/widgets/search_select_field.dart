import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Field pemilih dengan pencarian: ketuk untuk membuka bottom sheet
/// berisi kolom pencarian + daftar hasil yang difilter.
class SearchSelectField<T> extends StatelessWidget {
  const SearchSelectField({
    super.key,
    required this.label,
    required this.hint,
    required this.items,
    required this.value,
    required this.onChanged,
    required this.searchText,
    required this.itemBuilder,
  });

  final String label;
  final String hint;
  final List<T> items;
  final T? value;
  final ValueChanged<T?> onChanged;
  final String Function(T item) searchText;
  final Widget Function(T item) itemBuilder;

  Future<void> _open(BuildContext context) async {
    final result = await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SearchSheet(
        title: label,
        items: items,
        searchText: searchText,
        itemBuilder: itemBuilder,
      ),
    );
    if (result != null) onChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    final current = value;
    final display = current != null ? searchText(current) : null;

    return InkWell(
      onTap: items.isEmpty ? null : () => _open(context),
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        child: Text(
          display ?? hint,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: display != null
                    ? AppTheme.textPrimary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ),
    );
  }
}

class _SearchSheet<T> extends StatefulWidget {
  const _SearchSheet({
    required this.title,
    required this.items,
    required this.searchText,
    required this.itemBuilder,
  });

  final String title;
  final List<T> items;
  final String Function(T item) searchText;
  final Widget Function(T item) itemBuilder;

  @override
  State<_SearchSheet<T>> createState() => _SearchSheetState<T>();
}

class _SearchSheetState<T> extends State<_SearchSheet<T>> {
  final _controller = TextEditingController();
  String _query = '';

  List<T> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.items;
    return widget.items
        .where((i) => widget.searchText(i).toLowerCase().contains(q))
        .toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.72,
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Pilih ${widget.title}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Tutup',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextField(
                controller: _controller,
                autofocus: true,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Cari ${widget.title.toLowerCase()}...',
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _filtered.isEmpty
                  ? const Center(child: Text('Tidak ada hasil'))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _filtered.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = _filtered[index];
                        return InkWell(
                          onTap: () => Navigator.of(context).pop(item),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            child: widget.itemBuilder(item),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
