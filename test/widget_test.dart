import 'package:flutter_test/flutter_test.dart';

import 'package:cms_flutter_mobile_app/main.dart';

void main() {
  testWidgets('Clinic Portal app starts on the login screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const CapstoneClinicApp());

    expect(find.text('Colegio de Montalban Clinic'), findsOneWidget);
    expect(find.text('Student Health Portal'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}
