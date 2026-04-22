import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_client.dart';
import '../services/crypto_service.dart';
import '../services/favorites_service.dart';

class AppDependencyInjector extends StatelessWidget {
  final SharedPreferences prefs;
  final Widget child;

  const AppDependencyInjector({
    super.key,
    required this.prefs,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>(create: (_) => ApiClient()),
        ProxyProvider<ApiClient, CryptoService>(
          update: (_, apiClient, __) => CryptoService(apiClient),
        ),
        Provider<FavoritesService>(create: (_) => FavoritesService(prefs)),
      ],
      child: child,
    );
  }
}
