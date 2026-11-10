import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:practice_10_async/api/countdown.dart';
import 'package:practice_10_async/api/fake_api.dart';

void main() {
  testWidgets('unawaited save error reaches the zone, not the caller', (
    tester,
  ) async {
    final api = FakeApi();
    final first = api.save(6);
    await tester.pump(const Duration(seconds: 1));
    await first;
    Object? uncaught;
    var popped = false;
    runZonedGuarded(
      () {
        unawaited(api.save(6));
        popped = true;
      },
      (error, stack) {
        uncaught = error;
      },
    );
    expect(popped, isTrue);
    expect(uncaught, isNull);
    await tester.pump(const Duration(seconds: 1));
    expect(uncaught, isA<StateError>());
    debugPrint('Unhandled Exception: $uncaught');
  });
  testWidgets('broken subscription demonstrates post-dispose updates', (
    tester,
  ) async {
    final events = <String>[];
    final oldPrint = debugPrint;
    debugPrint = (message, {wrapWidth}) {
      if (message != null) events.add(message);
    };
    try {
      await tester.pumpWidget(const MaterialApp(home: BrokenCountdown()));
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
      await tester.pumpWidget(const SizedBox());
      for (var i = 0; i < 7; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
      expect(events.where((line) => line.startsWith('tick ')).last, 'tick 0');
      expect(
        events
            .where(
              (line) => line.startsWith('setState() called after dispose()'),
            )
            .length,
        7,
      );
      oldPrint(
        events.firstWhere(
          (line) => line.startsWith('setState() called after dispose()'),
        ),
      );
      oldPrint(
        'Without cancellation: ${events.where((line) => line.startsWith("tick ")).join(", ")}',
      );
    } finally {
      debugPrint = oldPrint;
    }
  });
}

class BrokenCountdown extends StatefulWidget {
  const BrokenCountdown({super.key});
  @override
  State<BrokenCountdown> createState() => _BrokenCountdownState();
}

class _BrokenCountdownState extends State<BrokenCountdown> {
  @override
  void initState() {
    super.initState();
    // Deliberate broken example: finite stream, no cancellation on disposal.
    countdown(10).listen((value) {
      try {
        setState(() {});
      } on FlutterError catch (error) {
        // Capture the expected error so this experiment can finish to tick 0.
        debugPrint(error.toString().split('\n').first);
      }
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox();
}
