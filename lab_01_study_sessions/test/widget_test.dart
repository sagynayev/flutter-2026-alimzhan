import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_sessions/main.dart';
import 'package:study_sessions/models/study_session.dart';
import 'package:study_sessions/screens/session_form_screen.dart';

void main() {
  testWidgets('opens a detail and redirects an empty profile', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(
      find.text('Flutter Layout Practice for Responsive Campus Applications I'),
    );
    await tester.pumpAndSettle();
    expect(find.text('About'), findsOneWidget);
    expect(find.text('People (6)'), findsOneWidget);

    await tester.tap(find.text('Join'));
    await tester.pump();
    expect(find.text('Add your name in Profile first.'), findsOneWidget);
  });

  testWidgets('creates a session through the validated form', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('New session'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Title'),
      'Database revision',
    );
    await tester.tap(find.byType(DropdownButtonFormField<StudyCategory>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Programming').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Place'),
      'Room 210',
    );
    await tester.ensureVisible(find.text('Save'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.byType(SessionFormScreen), findsNothing);
    expect(find.text('Database revision'), findsOneWidget);
  });

  testWidgets('asks before closing a dirty form', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('New session'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Title'),
      'Changed',
    );
    await tester.pump();

    final formContext = tester.element(find.byType(SessionFormScreen));
    await Navigator.of(formContext).maybePop();
    await tester.pumpAndSettle();
    expect(find.text('Discard changes?'), findsOneWidget);
  });

  testWidgets('uses a grid on a tablet-sized screen', (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.byType(GridView), findsOneWidget);
  });
}
