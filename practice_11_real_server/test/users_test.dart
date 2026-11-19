import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:practice_11_users/core/api/api_client.dart';
import 'package:practice_11_users/core/api/api_exception.dart';
import 'package:practice_11_users/features/users/user.dart';
import 'package:practice_11_users/features/users/user_repository.dart';
import 'package:practice_11_users/features/users/users_model.dart';
import 'package:practice_11_users/main.dart';

final sample = jsonDecode(
  File('test/fixtures/user1.json').readAsStringSync(),
) as Map<String, dynamic>;

UserRepository repository(
  Future<http.Response> Function(http.Request) handler,
) => UserRepository(ApiClient(MockClient(handler)));

void main() {
  test('real JSON round trip, nested fields, nullable website and phone', () {
    final user = User.fromJson(sample);
    expect(user.address.geo.lat, -37.3159);
    expect(user.phoneDigits, '1770736803156442');
    expect(user.toJson(), sample);
    expect(User.fromJson(user.toJson()), user);
    expect(User.fromJson({...sample}..remove('website')).website, isNull);
    expect(
      () => User.fromJson({...sample, 'id': '1'}),
      throwsA(isA<TypeError>()),
    );
  });

  test('GET list, object, POST shape and assigned id', () async {
    final requests = <http.Request>[];
    final repo = repository((request) async {
      requests.add(request);
      if (request.method == 'POST') {
        expect(request.headers['content-type'], 'application/json');
        expect(jsonDecode(request.body)['address'], sample['address']);
        return http.Response(jsonEncode({...sample, 'id': 11}), 201);
      }
      return http.Response(
        jsonEncode(request.url.path == '/users' ? [sample] : sample),
        200,
      );
    });
    expect((await repo.getAll()).length, 1);
    expect((await repo.getById(1)).id, 1);
    expect((await repo.create(User.fromJson(sample))).id, 11);
    expect(requests.every((r) => r.url.scheme == 'https'), isTrue);
    expect(
      requests.every((r) => r.headers['accept'] == 'application/json'),
      isTrue,
    );
    repo.close();
  });

  for (final entry in <int, Type>{
    401: UnauthorizedException,
    404: NotFoundException,
    503: ServerException,
  }.entries) {
    test('HTTP ${entry.key} checked before invalid JSON', () async {
      final repo = repository(
        (_) async => http.Response('not JSON', entry.key),
      );
      await expectLater(
        repo.getById(999),
        throwsA(predicate((e) => e.runtimeType == entry.value)),
      );
      repo.close();
    });
  }

  for (final body in ['not JSON', '{}', '[{"id":"1"}]']) {
    test('bad response $body mapped to application error', () async {
      final repo = repository((_) async => http.Response(body, 200));
      await expectLater(repo.getAll(), throwsA(isA<BadResponseException>()));
      repo.close();
    });
  }

  test('SocketException and ClientException mapped to offline', () async {
    for (final error in [
      const SocketException('offline'),
      http.ClientException('offline'),
    ]) {
      final repo = repository((_) async => throw error);
      await expectLater(repo.getAll(), throwsA(isA<NoConnectionException>()));
      repo.close();
    }
  });

  testWidgets('ten second timeout on a request that never responds', (
    tester,
  ) async {
    final pending = Completer<http.Response>();
    final repo = repository((_) => pending.future);
    final check = expectLater(
      repo.getAll(),
      throwsA(isA<NoConnectionException>()),
    );
    await tester.pump(const Duration(seconds: 10));
    await check;
    pending.complete(http.Response('[]', 200));
    repo.close();
  });

  test('model recovers from offline and inserts created user first', () async {
    var offline = true;
    final repo = repository((request) async {
      if (offline) throw const SocketException('offline');
      return http.Response(
        jsonEncode(request.method == 'POST' ? {...sample, 'id': 11} : [sample]),
        request.method == 'POST' ? 201 : 200,
      );
    });
    final model = UsersModel(repo);
    await model.load();
    expect(model.error, isA<NoConnectionException>());
    expect(model.loading, isFalse);
    offline = false;
    await model.load();
    expect(model.error, isNull);
    expect(model.items.length, 1);
    expect(await model.create(User.fromJson(sample)), isTrue);
    expect(model.items.first.id, 11);
    model.dispose();
  });

  testWidgets(
    'form disables Save, sends one POST, stays on 500 and then succeeds',
    (tester) async {
      final response = Completer<http.Response>();
      var posts = 0;
      final model = UsersModel(
        repository((request) async {
          if (request.method == 'GET') {
            return http.Response(jsonEncode([sample]), 200);
          }
          posts++;
          if (posts == 1) return response.future;
          return http.Response(
            jsonEncode({...sample, 'id': 11, 'name': 'Alimzhan'}),
            201,
          );
        }),
      );
      await model.load();
      await tester.pumpWidget(
        ChangeNotifierProvider.value(value: model, child: const App()),
      );
      await tester.tap(find.byTooltip('New user'));
      await tester.pumpAndSettle();
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Alimzhan');
      await tester.enterText(fields.at(1), 'alimzhan');
      await tester.enterText(fields.at(2), 'alimzhan@example.com');
      await tester.tap(find.text('Save'));
      await tester.pump();
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      await tester.tap(find.byType(FilledButton));
      expect(posts, 1);
      response.complete(http.Response('{}', 500));
      await tester.pumpAndSettle();
      expect(find.text('Server error: 500'), findsOneWidget);
      expect(find.text('New user'), findsOneWidget);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(posts, 2);
      expect(find.text('Alimzhan'), findsOneWidget);
      expect(find.text('New user'), findsNothing);
      await tester.pumpWidget(const SizedBox());
      model.dispose();
    },
  );

  test('dispose during load causes no notification after disposal', () async {
    final pending = Completer<http.Response>();
    final model = UsersModel(repository((_) => pending.future));
    final load = model.load();
    model.dispose();
    pending.complete(http.Response('[]', 200));
    await load;
  });
}
