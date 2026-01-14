import 'package:flutter_bloc/flutter_bloc.dart';

extension BlocExt<T, S> on Bloc<T, S> {
  void safeEmit(S state, Emitter<S> emit) {
    if (!isClosed) {
      emit(state);
    }
  }

  void safeAdd(T event) {
    if (!isClosed) {
      add(event);
    }
  }
}

extension EmitterExt<S> on Emitter<S> {
  void safe(S state) {
    try {
      call(state);
    } catch (e) {
      // Emitter is closed, silently ignore
    }
  }
}

extension CubitExt<T> on Cubit<T> {
  void safeEmit(T state) {
    if (!isClosed) {
      // gets rid of the warning
      // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
      emit(state);
    }
  }
}
