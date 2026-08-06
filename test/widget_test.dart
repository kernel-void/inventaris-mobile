import 'package:flutter_test/flutter_test.dart';

import 'package:inventaris_mobile/main.dart';

void main() {
  testWidgets('App boots without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const InventarisApp());
    // Beri waktu cukup agar cek status maintenance (/status) selesai
    // sehingga tidak ada pending timer dari Dio saat test berakhir.
    await tester.pump(const Duration(seconds: 21));

    expect(find.byType(InventarisApp), findsOneWidget);
  });
}
