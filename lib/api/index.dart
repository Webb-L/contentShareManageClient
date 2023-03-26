import 'dart:convert';
import 'dart:io';

import 'package:encrypt/encrypt.dart' as Encrypt;
import 'package:shared_preferences/shared_preferences.dart';

class MyHttpClient {
  final HttpClient _httpClient = HttpClient();
  late Encrypt.Key key;
  late Encrypt.Encrypter encrypter;
  late Encrypt.IV iv;
  String _serverUrl = "";
  String _serverPass = "";
  String _token = "";

  void init() async {
    var sharedPreference = await SharedPreferences.getInstance();
    key =
        Encrypt.Key.fromUtf8(sharedPreference.getString("encryptionKey") ?? "");
    encrypter = Encrypt.Encrypter(Encrypt.AES(key));
    iv = Encrypt.IV
        .fromUtf8(sharedPreference.getString("encryptionOffset") ?? "");
    _serverUrl = sharedPreference.getString("serverUrl") ?? "";
    _serverPass = sharedPreference.getString("serverPass") ?? "";
    _token = sharedPreference.getString("token") ?? "";
  }

  void setUrl(url) {
    _serverUrl = url;
  }

  void setPass(pass) {
    _serverPass = pass;
  }

  Future<String> get(String path, [String parameter = ""]) async {
    final request = await _httpClient.getUrl(buildUri(path, parameter));
    request.headers.add("Authorization", _token);
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    if (response.statusCode != 200) throw Exception(responseBody);
    return responseBody;
  }

  Uri buildUri(String path, [String parameter = ""]) =>
      Uri.parse("$_serverUrl/$path/?password=$_serverPass$parameter");

  Future<String> post(String path, Map<String, dynamic> data,
      [String parameter = ""]) async {
    final request = await _httpClient.postUrl(buildUri(path, parameter));
    request.headers.add("Authorization", _token);
    request.headers.contentType = ContentType.json;
    request.add(utf8.encode(jsonEncode(data)));
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    if (response.statusCode != 200) throw Exception(responseBody);
    return responseBody;
  }

  Future<String> put(String path, Map<String, dynamic> data,
      [String parameter = ""]) async {
    final request = await _httpClient.putUrl(buildUri(path, parameter));
    request.headers.add("Authorization", _token);
    request.headers.contentType = ContentType.json;
    request.add(utf8.encode(jsonEncode(data)));
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    if (response.statusCode != 200) throw Exception(responseBody);
    return responseBody;
  }

  Future<String> delete(String path, [String parameter = ""]) async {
    final request = await _httpClient.deleteUrl(buildUri(path, parameter));
    request.headers.add("Authorization", _token);
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    if (response.statusCode != 200) throw Exception(responseBody);
    return responseBody;
  }
}
