import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:crypto_tracker_lite/l10n/app_localizations.dart';
import 'package:crypto_tracker_lite/bloc/locale_bloc.dart';

void main() {
  testWidgets('i18n Smoke Test: Switching language updates UI text', (WidgetTester tester) async {
    // 1. Setup mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // 2. Pump the widget with LocaleBloc and localized MaterialApp
    await tester.pumpWidget(
      BlocProvider<LocaleBloc>(
        create: (_) => LocaleBloc(prefs),
        child: BlocBuilder<LocaleBloc, LocaleState>(
          builder: (context, state) {
            return MaterialApp(
              locale: state.locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: Builder(
                  builder: (context) => Text(AppLocalizations.of(context)!.favorites),
                ),
              ),
            );
          },
        ),
      ),
    );

    // 3. Verify initial Spanish text (default)
    expect(find.text('Favoritos'), findsOneWidget);
    expect(find.text('Favorites'), findsNothing);

    // 4. Trigger language change to English
    final localeBloc = tester.element(find.byType(Scaffold)).read<LocaleBloc>();
    localeBloc.add(ChangeLocale(const Locale('en')));
    await tester.pumpAndSettle();

    // 5. Verify text updated to English
    expect(find.text('Favorites'), findsOneWidget);
    expect(find.text('Favoritos'), findsNothing);

    // 6. Trigger language change back to Spanish
    localeBloc.add(ChangeLocale(const Locale('es')));
    await tester.pumpAndSettle();

    // 7. Verify text updated back to Spanish
    expect(find.text('Favoritos'), findsOneWidget);
  });
}
