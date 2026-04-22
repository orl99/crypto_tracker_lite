// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'CryptoTracker Lite';

  @override
  String get detail => 'Detalle';

  @override
  String get currentPrice => 'Precio actual';

  @override
  String get high24h => 'Máximo 24h';

  @override
  String get low24h => 'Mínimo 24h';

  @override
  String get marketCap => 'Capitalización';

  @override
  String get volume24h => 'Volumen 24h';

  @override
  String get historicPrice7d => 'Precio histórico (7 días)';

  @override
  String get aboutSection => 'Acerca de';

  @override
  String get chartStart => 'Inicio';

  @override
  String get chartToday => 'Hoy';

  @override
  String get rateLimitChart => 'Límite de API alcanzado. Espera unos segundos.';

  @override
  String get errorLoadingChart => 'Error cargando gráfica';

  @override
  String get favorites => 'Favoritos';

  @override
  String get favoritesTitle => 'Favoritos ⭐';

  @override
  String get noFavoritesYet => 'Aún no tienes favoritos';

  @override
  String get noFavoritesHint => 'Toca la estrella en cualquier moneda\npara añadirla aquí';

  @override
  String get profile => 'Perfil';

  @override
  String get myProfile => 'Mi perfil';

  @override
  String get nameLabel => 'Nombre';

  @override
  String get emailLabel => 'Correo';

  @override
  String get settings => 'Configuración';

  @override
  String get errorTitle => 'Hubo un problema 😢';

  @override
  String get errorRateLimitBody => 'La API de CoinGecko tiene límites de velocidad. Por favor, espera unos momentos y presiona \"Reintentar\".';

  @override
  String get retry => 'Reintentar';

  @override
  String get rateLimitBanner => 'Límite de solicitudes excedido.\nReintentando...';

  @override
  String get language => 'Idioma';

  @override
  String get spanish => 'Español';

  @override
  String get english => 'Inglés';
}
