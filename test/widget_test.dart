import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:momo_wallet/main.dart';

void main() {
  testWidgets('Wallet screen shows the balance card', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MomoWalletApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('MoMo Wallet'), findsOneWidget);
    expect(find.text('Balance'), findsOneWidget);
  });
}
