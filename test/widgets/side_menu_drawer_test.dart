import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_tracker_lite/widgets/side_menu_drawer.dart';
import 'package:crypto_tracker_lite/theme/app_colors.dart';
import '../helpers/test_helper.dart';

void main() {
  setUpAll(() {
    setupMockImageHttp();
  });

  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: Scaffold(
        drawer: SideMenuDrawer(),
      ),
    );
  }

  testWidgets('SideMenuDrawer renders profile information correctly', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(createWidgetUnderTest());
      
      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      expect(find.text('Bryan Vazquez'), findsOneWidget);
      expect(find.text('bryan@correo.com'), findsOneWidget);
    });
  });

  testWidgets('SideMenuDrawer renders all menu items', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(createWidgetUnderTest());
      
      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      expect(find.text('Favoritos'), findsOneWidget);
      expect(find.text('Perfil'), findsOneWidget);
      expect(find.text('Configuración'), findsOneWidget);
    });
  });

  testWidgets('SideMenuDrawer has correct styling from AppColors', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(createWidgetUnderTest());
      
      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      final drawer = tester.widget<Drawer>(find.byType(Drawer));
      expect(drawer.backgroundColor, AppColors.card);
    });
  });
}
