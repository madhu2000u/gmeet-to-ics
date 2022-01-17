import 'dart:async';

import 'package:googleapis/calendar/v3.dart' as cal;
import 'package:googleapis_auth/auth_io.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'secrets.dart';

class CredentialsProvider {
  static const String typeKey = "type";
  static const String dataKey = "data";
  static const String expiryKey = "expiry";
  static const String refreshKey = "refreshToken";

  CredentialsProvider();

  void prompt(String url) async {
    await launch(url);
  }

  Future<void> saveCreds(AuthClient _client) async {
    final _storage = const FlutterSecureStorage();

    await _storage.write(
        key: typeKey, value: _client.credentials.accessToken.type);
    await _storage.write(
        key: dataKey, value: _client.credentials.accessToken.data);
    await _storage.write(
        key: expiryKey,
        value: _client.credentials.accessToken.expiry.toIso8601String());
    await _storage.write(
        key: refreshKey, value: _client.credentials.refreshToken);
  }

  Future<AuthClient> get client async {
    await Firebase.initializeApp();
    final _storage = const FlutterSecureStorage();

    var _clientId = new ClientId(Secret.getId(), "");
    const _scopes = const [cal.CalendarApi.calendarScope];
    String refreshToken = await _storage.read(key: refreshKey) ?? "";

    late AuthClient _client;
    if (refreshToken == "") {
      await clientViaUserConsent(_clientId, _scopes, prompt)
          .then((AuthClient c) async {
        await saveCreds(c);
        _client = c;
      });
    } else {
      String data = await _storage.read(key: dataKey) ?? "";
      String type = await _storage.read(key: typeKey) ?? "";
      String expiry = await _storage.read(key: expiryKey) ?? "";

      AccessToken accessToken =
          AccessToken(type, data, DateTime.tryParse(expiry)!);

      AccessCredentials creds = await refreshCredentials(_clientId,
          AccessCredentials(accessToken, refreshToken, _scopes), http.Client());
      http.Client c = http.Client();
      AuthClient authClient = autoRefreshingClient(_clientId, creds, c);
      _client = authClient;
    }
    return _client;
  }
}
