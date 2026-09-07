import 'package:flutter_test/flutter_test.dart';
import 'package:krishibazar_flutter/Core/Dependency/dependency.dart';
import 'package:krishibazar_flutter/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(Dependency.wrapWithProviders(const KrishiBazarApp()));
    expect(find.byType(KrishiBazarApp), findsOneWidget);
  });
}
