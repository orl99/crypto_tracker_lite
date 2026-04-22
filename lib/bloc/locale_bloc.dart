import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ──────────────────────────────────────────────
// Events
// ──────────────────────────────────────────────

/// Base event for locale-related actions.
abstract class LocaleEvent {}

/// Dispatched when the user selects a new language from the UI.
class ChangeLocale extends LocaleEvent {
  final Locale locale;
  ChangeLocale(this.locale);
}

// ──────────────────────────────────────────────
// State
// ──────────────────────────────────────────────

/// Holds the currently active [Locale].
///
/// When this state changes, the [MaterialApp] rebuilds with the new locale,
/// causing all `AppLocalizations.of(context)` calls to return updated strings.
class LocaleState {
  final Locale locale;
  const LocaleState(this.locale);
}

// ──────────────────────────────────────────────
// BLoC
// ──────────────────────────────────────────────

/// [LocaleBloc] manages the application's active locale and persists the
/// user's language preference across sessions via [SharedPreferences].
///
/// On startup it reads the stored language code (key: `app_locale`).
/// If no preference is found, it defaults to Spanish (`es`).
class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  final SharedPreferences _prefs;

  static const String _prefsKey = 'app_locale';
  static const Locale _defaultLocale = Locale('es');

  /// Creates a [LocaleBloc] and loads the persisted locale from [prefs].
  LocaleBloc(SharedPreferences prefs)
      : _prefs = prefs,
        super(LocaleState(_loadSavedLocale(prefs))) {
    on<ChangeLocale>(_onChangeLocale);
  }

  /// Reads the saved language code from [SharedPreferences].
  /// Returns the corresponding [Locale] or [_defaultLocale] if absent.
  static Locale _loadSavedLocale(SharedPreferences prefs) {
    final code = prefs.getString(_prefsKey);
    if (code != null) {
      return Locale(code);
    }
    return _defaultLocale;
  }

  /// Handles [ChangeLocale] events by persisting the new preference
  /// and emitting the updated [LocaleState].
  Future<void> _onChangeLocale(ChangeLocale event, Emitter<LocaleState> emit) async {
    await _prefs.setString(_prefsKey, event.locale.languageCode);
    emit(LocaleState(event.locale));
  }
}
