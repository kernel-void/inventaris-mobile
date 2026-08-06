import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class MasterFormField {
  const MasterFormField({
    required this.id,
    required this.label,
    this.hint,
    this.initialValue = '',
    this.maxLines = 1,
  });

  final String id;
  final String label;
  final String? hint;
  final String initialValue;
  final int maxLines;
}

/// Bottom sheet untuk tambah/edit master (kategori/ruangan).
/// Mengembalikan `Map<String, String>` berisi nilai per id field.
Future<Map<String, String>?> showMasterFormSheet({
  required BuildContext context,
  required String title,
  required List<MasterFormField> fields,
  required String submitLabel,
}) {
  return showModalBottomSheet<Map<String, String>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _MasterFormSheet(
      title: title,
      fields: fields,
      submitLabel: submitLabel,
    ),
  );
}

class _MasterFormSheet extends StatefulWidget {
  const _MasterFormSheet({
    required this.title,
    required this.fields,
    required this.submitLabel,
  });

  final String title;
  final List<MasterFormField> fields;
  final String submitLabel;

  @override
  State<_MasterFormSheet> createState() => _MasterFormSheetState();
}

class _MasterFormSheetState extends State<_MasterFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final f in widget.fields)
        f.id: TextEditingController(text: f.initialValue),
    };
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop({
      for (final f in widget.fields) f.id: _controllers[f.id]!.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(widget.title,
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    IconButton(
                      tooltip: 'Tutup',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(PhosphorIcons.x),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                for (var i = 0; i < widget.fields.length; i++) ...[
                  TextFormField(
                    controller: _controllers[widget.fields[i].id],
                    maxLines: widget.fields[i].maxLines,
                    decoration: InputDecoration(
                      labelText: widget.fields[i].label,
                      hintText: widget.fields[i].hint,
                      alignLabelWithHint: widget.fields[i].maxLines > 1,
                    ),
                    validator: i == 0
                        ? (v) => v == null || v.trim().isEmpty
                            ? '${widget.fields[i].label} wajib diisi'
                            : null
                        : null,
                  ),
                  if (i < widget.fields.length - 1) const SizedBox(height: 12),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _submit,
                  child: Text(widget.submitLabel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
