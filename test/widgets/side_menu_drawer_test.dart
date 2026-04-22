import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_tracker_lite/widgets/side_menu_drawer.dart';
import 'package:crypto_tracker_lite/theme/app_colors.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes for HttpClient to handle NetworkImage in tests
class MockHttpClient extends Mock implements HttpClient {}
class MockHttpClientRequest extends Mock implements HttpClientRequest {}
class MockHttpClientResponse extends Mock implements HttpClientResponse {}
class MockHttpHeaders extends Mock implements HttpHeaders {}

class _MockHttpOverrides extends HttpOverrides {
  final HttpClient client;
  _MockHttpOverrides(this.client);
  @override
  HttpClient createHttpClient(SecurityContext? context) => client;
}

void main() {
  setUpAll(() {
    final mockClient = MockHttpClient();
    final mockRequest = MockHttpClientRequest();
    final mockResponse = MockHttpClientResponse();
    final mockHeaders = MockHttpHeaders();

    HttpOverrides.global = _MockHttpOverrides(mockClient);

    registerFallbackValue(Uri());

    when(() => mockClient.getUrl(any())).thenAnswer((_) async => mockRequest);
    when(() => mockRequest.headers).thenReturn(mockHeaders);
    when(() => mockRequest.close()).thenAnswer((_) async => mockResponse);
    when(() => mockResponse.statusCode).thenReturn(200);
    when(() => mockResponse.reasonPhrase).thenReturn('OK');
    when(() => mockResponse.contentLength).thenReturn(_transparentImage.length);
    when(() => mockResponse.compressionState).thenReturn(HttpClientResponseCompressionState.notCompressed);
    when(() => mockResponse.listen(
      any(),
      onError: any(named: 'onError'),
      onDone: any(named: 'onDone'),
      cancelOnError: any(named: 'cancelOnError'),
    )).thenAnswer((invocation) {
      final onData = invocation.positionalArguments[0] as void Function(List<int>);
      onData(_transparentImage);
      final onDone = invocation.namedArguments[#onDone] as void Function()?;
      onDone?.call();
      return _MockStreamSubscription<List<int>>();
    });
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

class _MockStreamSubscription<T> extends Mock implements StreamSubscription<T> {
  @override
  Future<void> cancel() async {}
}

final List<int> _transparentImage = [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
];
