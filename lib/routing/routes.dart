enum Routes {
  splash(name: 'splash', path: '/splash', fullPath: '/splash'),
  account(name: 'account', path: '/account', fullPath: '/account'),
  scan(name: 'scan', path: '/scan', fullPath: '/scan'),
  manualScan(name: 'manualScan', path: '/manual-scan', fullPath: '/scan/manual-scan'),
  cameraScan(name: 'cameraScan', path: '/camera-scan', fullPath: '/scan/camera-scan'),
  discard(name: 'discard', path: '/discard', fullPath: '/discard'),
  technicalDetails(name: 'technicalDetails', path: '/technical-details', fullPath: '/technical-details'),
  lookup(name: 'lookup', path: '/lookup', fullPath: '/lookup'),
  lookupDetails(name: 'discardDetails', path: '/lookup/discard-details', fullPath: '/lookup/discard-details'),
  test(name: 'test', path: '/test', fullPath: '/test')
  ;

  const Routes({required this.name, required this.path, required this.fullPath});

  final String name;
  final String path;
  final String fullPath;
}
