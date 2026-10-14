import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screens_lead/edit_screen.dart';
import 'package:screens_lead/main.dart';

void main() {
  Future<void> openEditor(WidgetTester tester) async {
    await tester.tap(find.text('Aida Akhmetova'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
  }

  Future<void> requestBack(WidgetTester tester) async {
    final context = tester.element(find.byType(EditScreen));
    await Navigator.of(context).maybePop();
    await tester.pumpAndSettle();
  }

  testWidgets('edits a student name and returns it to detail', (tester) async {
    await tester.pumpWidget(const MyApp());
    await openEditor(tester);
    await tester.enterText(find.byType(TextField), 'Aida Nurlan');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Aida Nurlan'), findsOneWidget);
  });

  testWidgets('asks before discarding a dirty name', (tester) async {
    await tester.pumpWidget(const MyApp());
    await openEditor(tester);
    await tester.enterText(find.byType(TextField), 'X');
    await tester.pump();
    await requestBack(tester);
    expect(find.text('Discard changes?'), findsOneWidget);
  });
}
