import 'dart:convert';
import 'authentication.dart';

class HttpBasicAuth implements Authentication {
  String? username;
  String? password;

  @override
  void applyToParams(Map<String, String?> headerParams) {
    String str = (username == null ? "" : username)! + ":" + (password == null ? "" : password!);
    headerParams["Authorization"] = "Basic " + base64.encode(utf8.encode(str));
  }

  void setUsernamePassword(String username, String password) {
    this.username = username;
    this.password = password;
  }
}
