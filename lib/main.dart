import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api/api_client.dart';
import 'services/crypto_service.dart';
import 'services/favorites_service.dart';
import 'bloc/crypto_list_bloc.dart';
import 'bloc/crypto_detail_bloc.dart';
import 'bloc/favorites_bloc.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({super.key, required this.prefs});

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
      child: MultiBlocProvider(
        providers: [
          BlocProvider<CryptoListBloc>(
            create: (context) => CryptoListBloc(context.read<CryptoService>())..add(FetchCryptoList()),
          ),
          BlocProvider<CryptoDetailBloc>(
            create: (context) => CryptoDetailBloc(context.read<CryptoService>()),
          ),
          BlocProvider<FavoritesBloc>(
            create: (context) => FavoritesBloc(context.read<FavoritesService>())..add(LoadFavorites()),
          ),
        ],
        child: MaterialApp(
          title: 'CryptoTracker Lite',
          debugShowCheckedModeBanner: false,
          theme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: const Color(0xFF1A1A1A), // Dark mode base
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1A1A1A),
              elevation: 0,
            ),
            colorScheme: const ColorScheme.dark(
              primary: Colors.amber,
              secondary: Colors.amberAccent,
            ),
          ),
          home: const HomePage(),
        ),
      ),
    );
  }
}
