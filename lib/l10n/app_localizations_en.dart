// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CryptoTracker Lite';

  @override
  String get detail => 'Detail';

  @override
  String get currentPrice => 'Current price';

  @override
  String get high24h => '24h High';

  @override
  String get low24h => '24h Low';

  @override
  String get marketCap => 'Market Cap';

  @override
  String get volume24h => '24h Volume';

  @override
  String get historicPrice7d => 'Historic price (7 days)';

  @override
  String get aboutSection => 'About';

  @override
  String get chartStart => 'Start';

  @override
  String get chartToday => 'Today';

  @override
  String get rateLimitChart => 'API limit reached. Wait a few seconds.';

  @override
  String get errorLoadingChart => 'Error loading chart';

  @override
  String get favorites => 'Favorites';

  @override
  String get favoritesTitle => 'Favorites ⭐';

  @override
  String get noFavoritesYet => 'You don\'t have favorites yet';

  @override
  String get noFavoritesHint => 'Tap the star on any coin\nto add it here';

  @override
  String get profile => 'Profile';

  @override
  String get myProfile => 'My profile';

  @override
  String get nameLabel => 'Name';

  @override
  String get emailLabel => 'Email';

  @override
  String get settings => 'Settings';

  @override
  String get errorTitle => 'Something went wrong 😢';

  @override
  String get errorRateLimitBody =>
      'The CoinGecko API has rate limits. Please wait a moment and press \"Retry\".';

  @override
  String get retry => 'Retry';

  @override
  String get rateLimitBanner => 'Request limit exceeded.\nRetrying...';

  @override
  String get language => 'Language';

  @override
  String get spanish => 'Spanish';

  @override
  String get english => 'English';
}
