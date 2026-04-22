import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_tracker_lite/pages/profile_page.dart';
import '../helpers/test_helper.dart';

void main() {
  setUpAll(() {
    setupMockImageHttp();
  });

  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: ProfilePage(),
    );
  }

  testWidgets('ProfilePage renders user information correctly', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(createWidgetUnderTest());
      
      // The name and email appear twice (header and detail item)
      expect(find.text('Bryan Vazquez'), findsAtLeast(1));
      expect(find.text('bryan@correo.com'), findsAtLeast(1));
      
      // Detail labels
      expect(find.text('Nombre'), findsOneWidget);
      expect(find.text('Correo'), findsOneWidget);
    });
  });

  testWidgets('ProfilePage icons are present', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(createWidgetUnderTest());
      
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
      expect(find.byIcon(Icons.mail_outline), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });
  });
}
