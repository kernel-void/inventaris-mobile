import 'package:flutter_test/flutter_test.dart';

import 'package:inventaris_mobile/main.dart';

void main() {
  testWidgets('App boots without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const InventarisApp());
    await tester.pump();

    expect(find.byType(InventarisApp), findsOneWidget);
  });
}
