import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:crypto_tracker_lite/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';

/// Localization delegates to use in test MaterialApp widgets.
const testLocalizationDelegates = [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

/// Supported locales for tests.
const testSupportedLocales = [Locale('es'), Locale('en')];

// Mock classes for HttpClient to handle NetworkImage in tests
class MockHttpClient extends Mock implements HttpClient {}
class MockHttpClientRequest extends Mock implements HttpClientRequest {}
class MockHttpClientResponse extends Mock implements HttpClientResponse {}
class MockHttpHeaders extends Mock implements HttpHeaders {}

class MockHttpOverrides extends HttpOverrides {
  final HttpClient client;
  MockHttpOverrides(this.client);
  @override
  HttpClient createHttpClient(SecurityContext? context) => client;
}

class MockStreamSubscription<T> extends Mock implements StreamSubscription<T> {
  @override
  Future<void> cancel() async {}
}

/// Helper to setup a mock HTTP client that returns a transparent 1x1 PNG image.
void setupMockImageHttp() {
  final mockClient = MockHttpClient();
  final mockRequest = MockHttpClientRequest();
  final mockResponse = MockHttpClientResponse();
  final mockHeaders = MockHttpHeaders();

  HttpOverrides.global = MockHttpOverrides(mockClient);

  if (!MocktailRegexp.isRegistered(Uri())) {
    registerFallbackValue(Uri());
  }

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
    return MockStreamSubscription<List<int>>();
  });
}

/// Mocks the path_provider platform channel to avoid MissingPluginException in tests.
void setupMockPathProvider() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const MethodChannel pathChannel = MethodChannel('plugins.flutter.io/path_provider');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(pathChannel, (MethodCall methodCall) async {
    return '.';
  });

  const MethodChannel sqfliteChannel = MethodChannel('com.tekartik.sqflite');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(sqfliteChannel, (MethodCall methodCall) async {
    if (methodCall.method == 'getDatabasesPath') {
      return '.';
    }
    return null;
  });
}

class MocktailRegexp {
  static final Set<Type> _registeredTypes = {};
  static bool isRegistered(dynamic value) {
    if (_registeredTypes.contains(value.runtimeType)) return true;
    _registeredTypes.add(value.runtimeType);
    return false;
  }
}

final List<int> _transparentImage = [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
];
