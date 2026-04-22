import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';

/// [AppBlocObserver] monitors all BLoC state changes and errors globally.
/// 
/// This is a best practice for tracking the application's flow and 
/// debugging issues in a centralized way.
class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    log('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}
