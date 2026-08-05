import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/category.dart';
import '../../providers/auth_provider.dart';
import '../../providers/item_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/master_form_sheet.dart';
import '../../widgets/search_field.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ItemProvider>().loadReferences();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openForm({Category? category}) async {
    final result = await showMasterFormSheet(
      context: context,
      title: category == null ? 'Tambah Kategori' : 'Edit Kategori',
      fields: [
        MasterFormField(
          id: 'name',
          label: 'Nama Kategori',
          hint: 'cth: Elektronik',
          initialValue: category?.name ?? '',
        ),
        MasterFormField(
          id: 'description',
          label: 'Deskripsi',
          hint: 'Opsional',
          initialValue: category?.description ?? '',
          maxLines: 3,
        ),
      ],
      submitLabel: category == null ? 'Simpan Kategori' : 'Simpan Perubahan',
    );
    if (result == null || !mounted) return;

    final provider = context.read<ItemProvider>();
    final payload = {
      'name': result['name'],
      'description': result['description']?.isEmpty ?? true
          ? null
          : result['description'],
    };
    try {
      if (category == null) {
        await provider.createCategory(payload);
      } else {
        await provider.updateCategory(category.id, payload);
      }
      _showSnack('Kategori berhasil ${category == null ? 'ditambahkan' : 'diperbarui'}');
    } catch (e) {
      _showSnack(e.toString(), isError: true);
    }
  }

  Future<void> _confirmDelete(Category category) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kategori?'),
        content: Text(
          'Kategori "${category.name}" akan dihapus. Tindakan ini tidak bisa dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    try {
      await context.read<ItemProvider>().deleteCategory(category.id);
      _showSnack('Kategori berhasil dihapus');
    } catch (e) {
      _showSnack(e.toString(), isError: true);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? AppTheme.danger : null,
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ItemProvider>();
    final auth = context.watch<AuthProvider>();
    final canCreate = auth.can('categories.create');
    final canUpdate = auth.can('categories.update');
    final canDelete = auth.can('categories.delete');

    Widget body;
    if (provider.loading && provider.categories.isEmpty) {
      body = const LoadingWidget(text: 'Memuat kategori...');
    } else if (provider.error != null && provider.categories.isEmpty) {
      body = ErrorView(
        message: provider.error!,
        onRetry: () => provider.loadReferences(),
      );
    } else {
      final q = _query.trim().toLowerCase();
      final categories = provider.categories.where((c) {
        if (q.isEmpty) return true;
        return [c.name, c.description ?? '']
            .join(' ')
            .toLowerCase()
            .contains(q);
      }).toList();

      body = Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: SearchField(
              controller: _searchController,
              hint: 'Cari kategori...',
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: categories.isEmpty
                ? Center(
                    child: Text(q.isNotEmpty
                        ? 'Tidak ditemukan'
                        : 'Belum ada kategori'),
                  )
                : RefreshIndicator(
                    onRefresh: () => provider.loadReferences(),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                      itemCount: categories.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return _CategoryCard(
                          category: category,
                          canManage: canUpdate || canDelete,
                          onEdit: canUpdate ? () => _openForm(category: category) : null,
                          onDelete: canDelete ? () => _confirmDelete(category) : null,
                        );
                      },
                    ),
                  ),
          ),
        ],
      );
    }

    return Scaffold(
      body: body,
      floatingActionButton: canCreate
          ? FloatingActionButton.extended(
              onPressed: () => _openForm(),
              icon: const Icon(Icons.add),
              label: const Text('Kategori'),
            )
          : null,
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.canManage,
    this.onEdit,
    this.onDelete,
  });

  final Category category;
  final bool canManage;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          radius: 20,
          backgroundColor:
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
          child: Icon(Icons.sell_outlined,
              size: 20, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(category.name, style: Theme.of(context).textTheme.titleSmall),
        subtitle: category.description != null && category.description!.isNotEmpty
            ? Text(category.description!,
                style: Theme.of(context).textTheme.bodySmall)
            : null,
        trailing: canManage
            ? PopupMenuButton<String>(
                tooltip: 'Aksi',
                onSelected: (value) {
                  if (value == 'edit') onEdit?.call();
                  if (value == 'delete') onDelete?.call();
                },
                itemBuilder: (context) => [
                  if (onEdit != null)
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                  if (onDelete != null)
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Hapus'),
                    ),
                ],
              )
            : null,
      ),
    );
  }
}
