import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

/// Indikator loading bersih (badge brand + teks), bukan spinner atau kotak skeleton.
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key, this.text = 'Memuat...'});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              PhosphorIcons.package,
              size: 26,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 14),
          Text(text, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
