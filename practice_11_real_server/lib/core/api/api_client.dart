import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_exception.dart';

class ApiClient {
  ApiClient(this._client, {this.host = 'jsonplaceholder.typicode.com'});
  factory ApiClient.standard() => ApiClient(http.Client());
  final http.Client _client;
  final String host;
  Map<String, String> get headers => {'Accept': 'application/json'};

  Future<http.Response> _send(Future<http.Response> Function() call) async {
    try {
      final response = await call().timeout(const Duration(seconds: 10));
      if (kDebugMode) {
        developer.log(
          '${response.request?.method} ${response.request?.url} -> ${response.statusCode}',
          name: 'api',
        );
      }
      return response;
    } on SocketException {
      throw const NoConnectionException();
    } on TimeoutException {
      throw const NoConnectionException();
    } on http.ClientException {
      throw const NoConnectionException();
    }
  }

  void _check(http.Response response) {
    final status = response.statusCode;
    if (status == 401) throw const UnauthorizedException();
    if (status == 404) throw const NotFoundException();
    if (status >= 500) throw ServerException(status);
    if (status < 200 || status >= 300) {
      throw BadResponseException('Unexpected HTTP status: $status');
    }
  }

  dynamic _decode(http.Response response) {
    try {
      return jsonDecode(response.body);
    } on FormatException catch (error) {
      throw BadResponseException(error.message);
    }
  }

  Future<dynamic> request(http.Request request, {int expected = 200}) async {
    request.headers.addAll(headers);
    final abort = Completer<void>();
    final timedRequest =
        http.AbortableRequest(
            request.method,
            request.url,
            abortTrigger: abort.future,
          )
          ..headers.addAll(request.headers)
          ..bodyBytes = request.bodyBytes;
    final watch = Stopwatch()..start();
    final http.Response response;
    try {
      response = await _send(() async {
        final streamed = await _client.send(timedRequest);
        return http.Response.fromStream(streamed);
      });
    } on ApiException catch (error) {
      if (kDebugMode) {
        developer.log(
          '${error.runtimeType} after ${watch.elapsedMilliseconds} ms',
          name: 'api',
        );
      }
      rethrow;
    } finally {
      // Future.timeout alone does not stop the underlying HTTP request.
      abort.complete();
    }
    _check(response);
    if (response.statusCode != expected) {
      throw BadResponseException(
        'Expected $expected, received ${response.statusCode}',
      );
    }
    return _decode(response);
  }

  void close() => _client.close();
}
