extension HttpStatusCode on int? {
  bool get isSuccessful {
    final code = this;
    if (code == null) {
      return false;
    }
    return code >= 200 && code < 300;
  }
}
