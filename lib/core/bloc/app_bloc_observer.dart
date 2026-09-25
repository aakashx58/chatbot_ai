import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Centralised bloc logging (debug builds only).
final class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    if (kDebugMode) log('${change.nextState}', name: bloc.runtimeType.toString());
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('Error', error: error, stackTrace: stackTrace, name: bloc.runtimeType.toString());
    super.onError(bloc, error, stackTrace);
  }
}
