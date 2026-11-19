import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'user.dart';

class UserRepository {
  UserRepository(this._api);
  final ApiClient _api;

  User _user(dynamic value, String path) {
    try {
      return User.fromJson(value as Map<String, dynamic>);
    } on TypeError catch (error) {
      throw BadResponseException('$path: $error');
    } on FormatException catch (error) {
      throw BadResponseException('$path: $error');
    }
  }

  Future<List<User>> getAll() async {
    final data = await _api.request(
      http.Request('GET', Uri.https(_api.host, '/users')),
    );
    if (data is! List) {
      throw const BadResponseException('users: expected a list');
    }
    return data.map((item) => _user(item, 'users')).toList();
  }

  Future<User> getById(int id) async {
    final path = '/users/$id';
    return _user(
      await _api.request(http.Request('GET', Uri.https(_api.host, path))),
      path,
    );
  }

  Future<User> create(User draft) async {
    final request = http.Request('POST', Uri.https(_api.host, '/users'))
      ..headers['Content-Type'] = 'application/json'
      ..body = jsonEncode(draft.toJson());
    return _user(await _api.request(request, expected: 201), 'POST users');
  }

  void close() => _api.close();
}
