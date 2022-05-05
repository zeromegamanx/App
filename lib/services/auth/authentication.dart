abstract class Authentication {
  /// Apply authentication settings to header and query params.
  void applyToParams(Map<String, String?> headerParams);
}
