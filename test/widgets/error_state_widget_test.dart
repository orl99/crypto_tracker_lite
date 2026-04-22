import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_tracker_lite/widgets/error_state_widget.dart';
import '../helpers/test_helper.dart';

void main() {
  testWidgets('ErrorStateWidget renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        supportedLocales: testSupportedLocales,
        localizationsDelegates: testLocalizationDelegates,
        home: Scaffold(
          body: ErrorStateWidget(onRetry: () {}),
        ),
      ),
    );

    expect(find.text('Hubo un problema 😢'), findsOneWidget);
    expect(find.textContaining('La API de CoinGecko'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
    expect(find.byIcon(Icons.priority_high), findsOneWidget);
  });

  testWidgets('Tapping Reintentar calls onRetry callback', (WidgetTester tester) async {
    bool retryCalled = false;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        supportedLocales: testSupportedLocales,
        localizationsDelegates: testLocalizationDelegates,
        home: Scaffold(
          body: ErrorStateWidget(onRetry: () => retryCalled = true),
        ),
      ),
    );

    await tester.tap(find.text('Reintentar'));
    expect(retryCalled, isTrue);
  });
}
