import 'package:flutter_test/flutter_test.dart';
import 'package:sagynayev_alimzhan_practice_07/main.dart';

void main() {
  testWidgets('shows the Practice 7 sign-up form', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text(practiceTitle), findsOneWidget);
    expect(find.text(studentName), findsWidgets);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
  });
}
