import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto_tracker_lite/bloc/locale_bloc.dart';

void main() {
  group('LocaleBloc Tests', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test('initial state defaults to Spanish when no preference saved', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final bloc = LocaleBloc(prefs);

      expect(bloc.state.locale, const Locale('es'));
      await bloc.close();
    });

    test('initial state loads saved locale from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({'app_locale': 'en'});
      final prefs = await SharedPreferences.getInstance();

      final bloc = LocaleBloc(prefs);

      expect(bloc.state.locale, const Locale('en'));
      await bloc.close();
    });

    blocTest<LocaleBloc, LocaleState>(
      'emits new locale when ChangeLocale is dispatched',
      build: () {
        return LocaleBloc(prefs);
      },
      act: (bloc) => bloc.add(ChangeLocale(const Locale('en'))),
      expect: () => [
        isA<LocaleState>().having((s) => s.locale, 'locale', const Locale('en')),
      ],
    );

    blocTest<LocaleBloc, LocaleState>(
      'persists locale to SharedPreferences on change',
      build: () {
        return LocaleBloc(prefs);
      },
      act: (bloc) => bloc.add(ChangeLocale(const Locale('en'))),
      verify: (_) {
        expect(prefs.getString('app_locale'), 'en');
      },
    );

    blocTest<LocaleBloc, LocaleState>(
      'supports switching back and forth between locales',
      build: () {
        return LocaleBloc(prefs);
      },
      act: (bloc) {
        bloc.add(ChangeLocale(const Locale('en')));
        bloc.add(ChangeLocale(const Locale('es')));
      },
      expect: () => [
        isA<LocaleState>().having((s) => s.locale, 'locale', const Locale('en')),
        isA<LocaleState>().having((s) => s.locale, 'locale', const Locale('es')),
      ],
    );
  });
}
