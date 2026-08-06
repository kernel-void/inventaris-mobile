import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../core/theme/app_theme.dart';
import '../../models/item.dart';
import '../../services/item_service.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_widget.dart';

class ItemDetailScreen extends StatefulWidget {
  const ItemDetailScreen({super.key, required this.itemId});

  final int itemId;

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  final _service = ItemService();

  Item? _item;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final item = await _service.show(widget.itemId);
      if (mounted) setState(() => _item = item);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Barang')),
      body: _loading
          ? const LoadingWidget(text: 'Memuat detail...')
          : _error != null
              ? ErrorView(message: _error!, onRetry: _load)
              : _buildDetail(context),
    );
  }

  Widget _buildDetail(BuildContext context) {
    final item = _item!;
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.pagePadding,
        8,
        AppTheme.pagePadding,
        32,
      ),
      children: [
        Container(
          padding: const EdgeInsets.all(AppTheme.cardPadding),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            border: Border.all(
              color: theme.dividerTheme.color ?? Colors.transparent,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.code,
                style: theme.textTheme.bodySmall?.copyWith(
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item.name,
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 14),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: context.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Stok ${item.stock} ${item.unit ?? ''}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: context.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.sectionGap),
        _InfoRow(icon: PhosphorIcons.tag, label: 'Kategori', value: item.category?.name ?? '-'),
        _InfoRow(icon: PhosphorIcons.building, label: 'Ruangan', value: item.room?.name ?? '-'),
        _InfoRow(icon: PhosphorIcons.medal, label: 'Merk', value: item.brand ?? '-'),
        _InfoRow(icon: PhosphorIcons.ruler, label: 'Satuan', value: item.unit ?? '-'),
        _InfoRow(
          icon: PhosphorIcons.calendarBlank,
          label: 'Tahun Perolehan',
          value: item.acquisitionYear ?? '-',
        ),
        _InfoRow(
          icon: PhosphorIcons.pulse,
          label: 'Kondisi',
          value: item.condition ?? '-',
        ),
        if (item.description != null && item.description!.isNotEmpty)
          _InfoRow(
            icon: PhosphorIcons.notebook,
            label: 'Keterangan',
            value: item.description!,
            multiline: true,
          ),
      ],
    ).animate().fadeIn(duration: 350.ms);
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.multiline = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool multiline;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: context.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: context.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
