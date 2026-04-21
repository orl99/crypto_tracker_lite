import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/crypto_service.dart';
import 'services/favorites_service.dart';
import 'bloc/crypto_list_bloc.dart';
import 'bloc/crypto_detail_bloc.dart';
import 'bloc/favorites_bloc.dart';
import 'pages/home_page.dart';
import 'providers/dependency_injection.dart';
import 'theme/app_colors.dart';

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
    return AppDependencyInjector(
      prefs: prefs,
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
            scaffoldBackgroundColor: AppColors.background, // Dark mode base
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.background,
              elevation: 0,
            ),
            colorScheme: const ColorScheme.dark(
              primary: AppColors.gold,
              secondary: AppColors.goldAlt,
            ),
          ),
          home: const HomePage(),
        ),
      ),
    );
  }
}
