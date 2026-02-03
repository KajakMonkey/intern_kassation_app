class AppConfig {
  const AppConfig._();

  static const latestReportsLimit = 25;
  static const maxImages = 10;
  static const maxNoteLength = 2500;

  static const discardedOrdersPageSize = 25;

  static const httpTimeout = Duration(seconds: 30);
  static const httpReceiveTimeout = Duration(seconds: 60);
  static const httpSendTimeout = Duration(seconds: 60);

  static const imageUploadTimeout = Duration(minutes: 2);

  static const tokenRefreshGracePeriod = Duration(minutes: 5);

  static const defaultCachingTtl = Duration(minutes: 15);
}
