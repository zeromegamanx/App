import 'authentication.dart';

class ApiKeyAuth implements Authentication {
  final String location;
  final String paramName;
  String? apiKey;
  String? apiKeyPrefix;

  ApiKeyAuth(this.location, this.paramName);

  @override
  void applyToParams(Map<String, String?> headerParams) {
    String? value;
    if (apiKeyPrefix != null) {
      value = '$apiKeyPrefix $apiKey';
    } else {
      value = apiKey;
    }

    if (location == 'header' && value != null) {
      headerParams[paramName] = value;
    }
  }
}
