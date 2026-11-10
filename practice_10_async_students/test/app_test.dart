import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practice_10_async/api/fake_api.dart';
import 'package:practice_10_async/main.dart';
import 'package:practice_10_async/students_screen.dart';
import 'package:practice_10_async/students_future_screen.dart';
import 'package:practice_10_async/countdown_screen.dart';

Future<void> finishLoad(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(seconds: 2));
  await tester.pump();
}

void main() {
  testWidgets('API delay, third failure, empty and alternate save failure', (
    tester,
  ) async {
    final api = FakeApi();
    for (var call = 1; call <= 4; call++) {
      final request = api.fetchStudents();
      if (call == 3) {
        final check = expectLater(
          request,
          throwsA(isA<NoConnectionException>()),
        );
        await tester.pump(const Duration(seconds: 2));
        await check;
      } else {
        await tester.pump(const Duration(seconds: 2));
        expect((await request).length, 6);
      }
    }
    final empty = FakeApi(empty: true).fetchStudents();
    await tester.pump(const Duration(seconds: 2));
    expect(await empty, isEmpty);
    final first = api.save(6);
    await tester.pump(const Duration(seconds: 1));
    await first;
    final second = expectLater(api.save(6), throwsA(isA<StateError>()));
    await tester.pump(const Duration(seconds: 1));
    await second;
  });

  testWidgets('manual loading, data, third-call error, retry and disposal', (
    tester,
  ) async {
    final api = FakeApi();
    await tester.pumpWidget(MaterialApp(home: StudentsScreen(api: api)));
    expect(find.text('Loading students…'), findsOneWidget);
    await finishLoad(tester);
    expect(find.text('Aida Nurlanova'), findsOneWidget);
    expect(find.text('—'), findsOneWidget);
    await tester.tap(find.byTooltip('Reload'));
    await finishLoad(tester);
    await tester.tap(find.byTooltip('Reload'));
    await finishLoad(tester);
    expect(find.text('Could not load students'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await finishLoad(tester);
    expect(find.text('Aida Nurlanova'), findsOneWidget);
    await tester.tap(find.byTooltip('Reload'));
    await tester.pumpWidget(const SizedBox());
    await finishLoad(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty is a view, not a spinner', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: StudentsScreen(api: FakeApi(empty: true))),
    );
    await finishLoad(tester);
    expect(find.text('No students yet'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('ten compact switches make only one request; retry recovers', (
    tester,
  ) async {
    final api = FakeApi();
    await tester.pumpWidget(MaterialApp(home: StudentsFutureScreen(api: api)));
    await finishLoad(tester);
    for (var i = 0; i < 10; i++) {
      await tester.tap(find.byType(Switch));
      await tester.pump();
    }
    expect(api.calls, 1);
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.byTooltip('Reload'));
      await finishLoad(tester);
    }
    expect(find.text('Could not load students'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await finishLoad(tester);
    expect(find.text('Aida Nurlanova'), findsOneWidget);
  });

  testWidgets('save blocks double tap, pops on success, stays on error', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('By hand'));
    await tester.pumpAndSettle();
    await finishLoad(tester);
    await tester.tap(find.byTooltip('Save'));
    await tester.pump();
    expect(
      tester
          .widget<FloatingActionButton>(find.byType(FloatingActionButton))
          .onPressed,
      isNull,
    );
    await tester.tap(find.byTooltip('Save'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Practice 10'), findsOneWidget);
    await tester.tap(find.text('By hand'));
    await tester.pumpAndSettle();
    await finishLoad(tester);
    await tester.tap(find.byTooltip('Save'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(find.text('server rejected 6'), findsOneWidget);
    expect(find.byType(StudentsScreen), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  for (final manual in [false, true]) {
    testWidgets('countdown ${manual ? "B" : "A"} stops after disposal', (
      tester,
    ) async {
      final logs = <String>[];
      final oldPrint = debugPrint;
      debugPrint = (message, {wrapWidth}) {
        if (message != null) logs.add(message);
      };
      try {
        await tester.pumpWidget(
          MaterialApp(
            home: manual ? const ManualCountdown() : const BuilderCountdown(),
          ),
        );
        for (var i = 0; i < 4; i++) {
          await tester.pump(const Duration(seconds: 1));
        }
        expect(find.text('7'), findsOneWidget);
        await tester.pumpWidget(const SizedBox());
        final count = logs.length;
        for (var i = 0; i < 4; i++) {
          await tester.pump(const Duration(seconds: 1));
        }
        expect(logs.length, count);
        expect(tester.takeException(), isNull);
      } finally {
        debugPrint = oldPrint;
      }
    });
  }

  testWidgets('event loop experiment records actual order', (tester) async {
    final events = <String>[];
    events.add('A');
    final timer = Future<void>.delayed(
      const Duration(seconds: 2),
      () => events.add('B'),
    );
    events.add('C');
    final request = FakeApi().fetchStudents().then(
      (list) => events.add('${list.length} students'),
    );
    await tester.pumpWidget(const MaterialApp(home: Text('First frame')));
    events.add('first frame');
    expect(events, ['A', 'C', 'first frame']);
    await tester.pump(const Duration(seconds: 2));
    await Future.wait([timer, request]);
    expect(events, ['A', 'C', 'first frame', 'B', '6 students']);
    debugPrint('Event order: ${events.join(", ")}');
  });
}
