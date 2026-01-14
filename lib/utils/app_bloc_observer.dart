import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

/// Logs the runtime type of the BLoC and the corresponding event or state change.
class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase<dynamic> bloc) {
    super.onCreate(bloc);
    log('${bloc.runtimeType} created');
  }

  @override
  void onTransition(Bloc<dynamic, dynamic> bloc, Transition<dynamic, dynamic> transition) {
    super.onTransition(bloc, transition);
    log('${bloc.runtimeType} $transition');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('${bloc.runtimeType} Error: $error StackTrace $stackTrace');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase<dynamic> bloc) {
    log('${bloc.runtimeType} closed');
    super.onClose(bloc);
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    final blocType = bloc.runtimeType;
    if (blocType.toString().contains('Bloc')) {
      return;
    }
    log('$blocType $change');
    super.onChange(bloc, change);
  }
}
