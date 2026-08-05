import 'package:flutter/material.dart';

/// Kolom pencarian konsisten untuk daftar referensi (kategori, ruangan).
class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    required this.controller,
    required this.hint,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      textInputAction: TextInputAction.search,
      onChanged: (v) {
        setState(() {});
        widget.onChanged?.call(v);
      },
      decoration: InputDecoration(
        hintText: widget.hint,
        isDense: true,
        prefixIcon: const Icon(Icons.search, size: 20),
        suffixIcon: widget.controller.text.isNotEmpty
            ? IconButton(
                tooltip: 'Hapus',
                icon: const Icon(Icons.close, size: 18),
                onPressed: () {
                  widget.controller.clear();
                  setState(() {});
                  widget.onChanged?.call('');
                },
              )
            : null,
      ),
    );
  }
}
