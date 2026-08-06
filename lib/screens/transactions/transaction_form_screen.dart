import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../models/item.dart';
import '../../models/room.dart';
import '../../providers/item_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/search_select_field.dart';

enum TransactionType { incoming, outgoing }

class TransactionFormScreen extends StatefulWidget {
  const TransactionFormScreen({super.key, required this.type});

  final TransactionType type;

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _date;
  int? _itemId;
  final _quantityController = TextEditingController(text: '1');
  Room? _destinationRoom;
  final _descriptionController = TextEditingController();

  bool _submitting = false;
  bool _loadingItems = true;
  String? _serverError;
  List<Item> _allItems = [];

  bool get _isIncoming => widget.type == TransactionType.incoming;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _date =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    _loadItems();
  }

  Future<void> _loadItems() async {
    final provider = context.read<ItemProvider>();
    try {
      final items = await provider.fetchAllItems();
      await provider.loadReferences();
      if (mounted) {
        setState(() {
          _allItems = items;
          _loadingItems = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingItems = false);
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final initial = DateTime.tryParse(_date) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _date =
            '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_itemId == null) {
      setState(() => _serverError = 'Silakan pilih barang.');
      return;
    }

    setState(() {
      _submitting = true;
      _serverError = null;
    });

    final provider = context.read<TransactionProvider>();
    final quantity = int.tryParse(_quantityController.text) ?? 1;

    try {
      if (_isIncoming) {
        await provider.storeIncoming(
          itemId: _itemId!,
          date: _date,
          quantity: quantity,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
        );
      } else {
        await provider.storeOutgoing(
          itemId: _itemId!,
          date: _date,
          quantity: quantity,
          destination: _destinationRoom?.name,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
        );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) setState(() => _serverError = e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ItemProvider>();
    final availableItems = _isIncoming
        ? _allItems
        : _allItems.where((i) => i.stock > 0).toList();
    final selectedItem = _itemId == null
        ? null
        : _allItems.where((i) => i.id == _itemId).firstOrNull;
    final selectedUnit = selectedItem?.unit;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isIncoming ? 'Tambah Barang Masuk' : 'Tambah Barang Keluar',
        ),
      ),
      body:
          SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_serverError != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: context.danger.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                PhosphorIcons.warningCircle,
                                size: 20,
                                color: context.danger,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _serverError!,
                                  style: TextStyle(color: context.danger),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      _buildSection('TRANSAKSI'),
                      SearchSelectField<Item>(
                        label: 'Barang',
                        hint: _loadingItems
                            ? 'Memuat barang...'
                            : 'Cari barang...',
                        items: availableItems,
                        value: selectedItem,
                        onChanged: (item) => setState(() => _itemId = item?.id),
                        searchText: (i) =>
                            '${i.code} — ${i.name} (stok ${i.stock})',
                        itemBuilder: (i) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            radius: 18,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.10),
                            child: Icon(
                              PhosphorIcons.package,
                              size: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          title: Text(
                            i.name,
                            style: Theme.of(context).textTheme.titleSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${i.code} · stok ${i.stock} ${i.unit ?? 'unit'}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: InkWell(
                              onTap: _pickDate,
                              borderRadius: BorderRadius.circular(14),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Tanggal',
                                  suffixIcon: Icon(PhosphorIcons.calendarBlank),
                                ),
                                child: Text(_date),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _quantityController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: selectedUnit != null
                                    ? 'Jumlah ($selectedUnit)'
                                    : 'Jumlah',
                              ),
                              validator: (v) {
                                final n = int.tryParse(v ?? '');
                                if (n == null || n < 1) return 'Min. 1';
                                final item = selectedItem;
                                if (!_isIncoming &&
                                    item != null &&
                                    n > item.stock) {
                                  return 'Melebihi stok (tersedia ${item.stock} ${item.unit ?? 'unit'})';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      if (_isIncoming)
                        if (selectedItem != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: context.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  PhosphorIcons.info,
                                  size: 18,
                                  color: context.primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Stok saat ini: ${selectedItem.stock} ${selectedItem.unit}',
                                    style: TextStyle(color: context.primary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      if (!_isIncoming) ...[
                        const SizedBox(height: 12),
                        DropdownButtonFormField<Room>(
                          isExpanded: true,
                          initialValue: _destinationRoom,
                          decoration: const InputDecoration(
                            labelText: 'Tujuan',
                          ),
                          hint: const Text('Pilih ruangan tujuan'),
                          items: provider.rooms
                              .map(
                                (r) => DropdownMenuItem(
                                  value: r,
                                  child: Text(r.name),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _destinationRoom = v),
                        ),
                      ],
                      _buildSection('CATATAN'),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Keterangan',
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 28),
                      FilledButton(
                        onPressed: _submitting ? null : _submit,
                        child: _submitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                _isIncoming
                                    ? 'Simpan Barang Masuk'
                                    : 'Simpan Barang Keluar',
                              ),
                      ),
                    ],
                  ),
                ),
              )
              .animate()
              .fadeIn(duration: 350.ms)
              .moveY(begin: 8, duration: 350.ms, curve: Curves.easeOut),
    );
  }
}
