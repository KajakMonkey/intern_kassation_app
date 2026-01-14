import 'package:intern_kassation_app/domain/errors/app_error_code.dart';
import 'package:intern_kassation_app/l10n/app_localizations.dart';

enum StorageErrorCodes implements AppErrorCode {
  unknown('GENERAL_UNKNOWN'),
  // secure storage
  secureStorageReadError('STORAGE_SECURE_STORAGE_READ_ERROR'),
  secureStorageWriteError('STORAGE_SECURE_STORAGE_WRITE_ERROR'),
  secureStorageDeleteError('STORAGE_SECURE_STORAGE_DELETE_ERROR'),
  // shared prefs
  sharedPrefsReadError('STORAGE_SHARED_PREFS_READ_ERROR'),
  sharedPrefsWriteError('STORAGE_SHARED_PREFS_WRITE_ERROR'),
  sharedPrefsDeleteError('STORAGE_SHARED_PREFS_DELETE_ERROR')
  ;

  const StorageErrorCodes(this.code);

  @override
  final String code;

  static StorageErrorCodes fromString(String code) {
    try {
      return StorageErrorCodes.values.firstWhere((e) => e.code == code);
    } catch (_) {
      return StorageErrorCodes.unknown;
    }
  }

  @override
  String getMessage(AppLocalizations l10n) => switch (this) {
    StorageErrorCodes.unknown => l10n.error_storage_unknown,
    // secure storage
    StorageErrorCodes.secureStorageReadError => l10n.error_storage_secure_storage_read_error,
    StorageErrorCodes.secureStorageWriteError => l10n.error_storage_secure_storage_write_error,
    StorageErrorCodes.secureStorageDeleteError => l10n.error_storage_secure_storage_delete_error,
    // shared prefs
    StorageErrorCodes.sharedPrefsReadError => l10n.error_storage_shared_prefs_read_error,
    StorageErrorCodes.sharedPrefsWriteError => l10n.error_storage_shared_prefs_write_error,
    StorageErrorCodes.sharedPrefsDeleteError => l10n.error_storage_shared_prefs_delete_error,
  };
}
