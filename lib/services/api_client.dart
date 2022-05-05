import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:core/core.dart';
import 'package:core/locator.dart';
import 'package:core/src/auth/auth.dart';
import 'package:core/src/device_info.dart';
import 'package:core/src/exception.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';

class ApiClient {
  int _timeOut = 100000; //30 s
  late Dio _dio;
  DioCacheManager? _dioCacheManager;
  Map<String, Authentication> _authentications = {};
  String? _baseUrl;
  DeviceInfo? _deviceInfo = locator<DeviceInfo>();
  String? _cookie;

  DioCacheManager? get dioCacheManager {
    _dioCacheManager ??= DioCacheManager(CacheConfig(baseUrl: _baseUrl));
    return _dioCacheManager;
  }

  ApiClient({required String baseUrl}) {
    this._baseUrl = baseUrl;
    BaseOptions options =
        BaseOptions(connectTimeout: _timeOut, receiveTimeout: _timeOut);
    _dio = Dio(options);
    _dio.interceptors
        .add(LogInterceptor(requestBody: true, responseBody: true));
    _dio.interceptors.add(dioCacheManager!.interceptor);
    //// Setup authentications (key: authentication name, value: authentication).
    _authentications[AuthNameConst.OAuth] = new OAuth();
    _authentications[AuthNameConst.Basic] = new HttpBasicAuth();
  }

  Map<String, String> _defaultHeaderMap = {};

  Future<Response> invokeAPI(
      String path,
      String method,
      Iterable<QueryParam> queryParams,
      Object? body,
      Map<String, String?> headerParams,
      Map<String, String> formParams,
      String contentType,
      List<String> authNames,
      {bool isDeviceInfo = true,
      Options? cacheOptions}) async {
    var connectionStatus = locator<FConnectivityPlus>().connectionStatus;
    print("path::: $path");
    if (connectionStatus == ConnectivityResult.none) throw NetworkException();

    _updateParamsForAuth(authNames, headerParams);
    if (isDeviceInfo) headerParams.addAll(await _getDeviceInfo());
    var ps = queryParams
        .where((p) => p.value != null)
        .map((p) => '${p.name}=${p.value}');
    String queryString = ps.isNotEmpty ? '?' + ps.join('&') : '';

    headerParams.addAll(_defaultHeaderMap);
    headerParams['Content-Type'] = contentType;
    //headerParams['cookie'] = globals.cookie;

    BaseOptions options =
        BaseOptions(connectTimeout: _timeOut, receiveTimeout: _timeOut);
    options.baseUrl = _baseUrl!;
    options.headers = headerParams;
    _dio = Dio(options);
    _dio.interceptors
        .add(LogInterceptor(requestBody: true, responseBody: true));
    _dio.interceptors.add(dioCacheManager!.interceptor);
    String pathApi = path + queryString;
    var msgBody = contentType == "application/x-www-form-urlencoded"
        ? formParams
        : serialize(body);
    switch (method) {
      case "POST":
        return _dio.post(pathApi, data: msgBody);
      case "PUT":
        return _dio.put(pathApi, data: msgBody);
      case "DELETE":
        return _dio.delete(pathApi, data: msgBody);
      case "PATCH":
        return _dio.patch(pathApi, data: msgBody);
      default:
        return _dio.get(pathApi);
    }
  }

  Future<Response> deleteWithBody(
    String path,
    Iterable<QueryParam> queryParams,
    Object body,
    Map<String, String> headerParams,
    String contentType,
    List<String> authNames, {
    bool isDeviceInfo = false,
  }) async {
    _updateParamsForAuth(authNames, headerParams);
    if (isDeviceInfo) headerParams.addAll(await _getDeviceInfo());
    var ps = queryParams
        .where((p) => p.value != null)
        .map((p) => '${p.name}=${p.value}');
    String queryString = ps.isNotEmpty ? '?' + ps.join('&') : '';

    String url = path + queryString;

    headerParams.addAll(_defaultHeaderMap);
    headerParams['Content-Type'] = contentType;
    //headerParams['cookie'] = globals.cookie;
    BaseOptions options =
        BaseOptions(connectTimeout: _timeOut, receiveTimeout: _timeOut);
    options.baseUrl = _baseUrl!;
    options.headers = headerParams;
    _dio = Dio(options);

    var response = await _dio
        .deleteUri(Uri.parse(url), data: serialize(body))
        .timeout(Duration(milliseconds: _timeOut));
    return response;
  }

  String serialize(Object? obj) {
    String serialized = '';
    if (obj == null) {
      serialized = '';
    } else {
      serialized = json.encode(obj);
    }
    return serialized;
  }

  /// Update query and header parameters based on authentication settings.
  /// @param authNames The authentications to apply
  void _updateParamsForAuth(
      List<String> authNames, Map<String, String?> headerParams) {
    authNames.forEach((authName) {
      Authentication? auth = _authentications[authName];
      if (auth == null)
        throw new ArgumentError("Authentication undefined: " + authName);
      auth.applyToParams(headerParams);
    });
  }

  Future<Map<String, String>> _getDeviceInfo() async {
    return {
      "x-device": await _deviceInfo!.deviceId ?? '',
      "x-devicetype": _deviceInfo!.deviceType,
      "via": _deviceInfo!.via,
    };
  }

  // Future<void> _updateDeviceInfo(Map<String, String> headerParams) async {
  //   headerParams ??= {};
  //   String ipAddress = await _deviceInfoManager.ipAdressV4;
  //   String macAdress = await _deviceInfoManager.macAddress;
  //   headerParams.addAll({
  //     "ipaddress": ipAddress,
  //     "macaddress": macAdress,
  //   });
  // }

  void setAccessToken(String accessToken) {
    _authentications.forEach((key, auth) {
      if (auth is OAuth) {
        auth.setAccessToken(accessToken);
      }
    });
  }

  void setBasicAuth(String username, String password) {
    _authentications.forEach((key, auth) {
      if (auth is HttpBasicAuth) {
        auth.setUsernamePassword(username, password);
      }
    });
  }

  updateCookie(String cookie) {
    _cookie = cookie;
  }

  String? getAccessToken() {
    for (var auth in _authentications.values) {
      if (auth is OAuth) {
        return auth.accessToken;
      }
    }
    return null;
  }

  dynamic validateFromData(Map<String, dynamic> json) {
    String? ec;
    String? s;
    if (json.containsKey("s")) s = json["s"].toString().toUpperCase();
    if (json.containsKey("ec")) ec = json["ec"].toString();
    if (s != null && s.isNotEmpty) {
      var em = json['em'];
      var data = json['d'];

      if (s == "OK") {
        return data as dynamic;
      } else {
        throw new ApiException(
            code: 500, serverErrorCode: ec, message: em, data: data);
      }
    }
  }
}

class QueryParam {
  String name;
  String value;
  QueryParam(this.name, this.value);
}
