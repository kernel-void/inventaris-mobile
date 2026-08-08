import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:inventaris_mobile/core/theme/app_theme.dart';
import 'package:inventaris_mobile/models/item.dart';
import 'package:inventaris_mobile/models/transaction_filter.dart';
import 'package:inventaris_mobile/widgets/transaction_filter_bar.dart';

void main() {
  testWidgets('date chip X clears the date filter', (WidgetTester tester) async {
    TransactionFilter? result;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: TransactionFilterBar(
            filter: const TransactionFilter(
              from: '2026-01-01',
              to: '2026-01-31',
            ),
            onChanged: (f) => result = f,
            hint: 'Cari...',
            loadItems: () async => <Item>[],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('01/01/2026 – 31/01/2026'), findsOneWidget);

    await tester.tap(find.byIcon(PhosphorIcons.x));
    await tester.pump();

    expect(result?.from, isNull);
    expect(result?.to, isNull);
  });

  testWidgets('empty search submission clears the search filter', (tester) async {
    TransactionFilter? result;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: TransactionFilterBar(
            filter: const TransactionFilter(search: 'laptop'),
            onChanged: (f) => result = f,
            hint: 'Cari...',
            loadItems: () async => <Item>[],
          ),
        ),
      ),
    );
    await tester.pump();

    final textField = tester.widget<TextField>(
      find.byType(TextField),
    );
    textField.controller?.text = '';
    await tester.pump();
    tester.widget<TextField>(find.byType(TextField)).onSubmitted!('');
    await tester.pump();

    expect(result?.search, isNull);
  });
}
