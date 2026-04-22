import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_tracker_lite/widgets/side_menu_drawer.dart';
import 'package:crypto_tracker_lite/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crypto_tracker_lite/bloc/locale_bloc.dart';
import 'package:mocktail/mocktail.dart';
import '../helpers/test_helper.dart';

class MockLocaleBloc extends Mock implements LocaleBloc {}

void main() {
  setUpAll(() {
    setupMockImageHttp();
  });

  late MockLocaleBloc mockLocaleBloc;

  setUp(() {
    mockLocaleBloc = MockLocaleBloc();
    when(() => mockLocaleBloc.state).thenReturn(const LocaleState(Locale('es')));
    when(() => mockLocaleBloc.stream).thenAnswer((_) => Stream.value(const LocaleState(Locale('es'))));
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      locale: const Locale('es'),
      supportedLocales: testSupportedLocales,
      localizationsDelegates: testLocalizationDelegates,
      home: BlocProvider<LocaleBloc>.value(
        value: mockLocaleBloc,
        child: const Scaffold(
          drawer: SideMenuDrawer(),
        ),
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
